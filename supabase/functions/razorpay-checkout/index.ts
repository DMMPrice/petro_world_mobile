import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const RAZORPAY_KEY_ID = Deno.env.get("RAZORPAY_KEY_ID")!;
const RAZORPAY_KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// HMAC-SHA256 signature generation using Web Crypto API
async function generateHmacSignature(message: string, secret: string): Promise<string> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign("HMAC", key, encoder.encode(message));
  return Array.from(new Uint8Array(signature))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

// Base64 encode key_id:key_secret for Basic Auth
const razorpayBasicAuth = btoa(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`);

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const path = url.pathname;

  // ─────────────────────────────────────────────────────────────────
  // POST /razorpay-checkout/create-order
  // Creates a Razorpay order server-side and returns order_id + key_id
  // ─────────────────────────────────────────────────────────────────
  if (path.endsWith("/create-order") && req.method === "POST") {
    try {
      const body = await req.json();
      const { amount_paise, receipt, notes } = body;

      if (!amount_paise || amount_paise < 100) {
        return json({ error: "amount_paise must be at least 100 (₹1)" }, 400);
      }

      const razorpayResp = await fetch("https://api.razorpay.com/v1/orders", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Basic ${razorpayBasicAuth}`,
        },
        body: JSON.stringify({
          amount: amount_paise,
          currency: "INR",
          receipt: receipt ?? `rcpt_${Date.now()}`,
          notes: notes ?? {},
        }),
      });

      const rzpData = await razorpayResp.json();

      if (!razorpayResp.ok) {
        console.error("Razorpay create-order error:", rzpData);
        return json({ error: rzpData?.error?.description ?? "Razorpay order creation failed" }, 500);
      }

      return json({
        razorpay_order_id: rzpData.id,
        key_id: RAZORPAY_KEY_ID,
        amount: rzpData.amount,
        currency: rzpData.currency,
      });
    } catch (err) {
      console.error("create-order exception:", err);
      return json({ error: String(err) }, 500);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // POST /razorpay-checkout/verify-payment
  // Verifies HMAC signature, then creates the order in the database
  // and pushes it to Shiprocket.
  // ─────────────────────────────────────────────────────────────────
  if (path.endsWith("/verify-payment") && req.method === "POST") {
    try {
      const body = await req.json();
      const {
        razorpay_order_id,
        razorpay_payment_id,
        razorpay_signature,
        address_id,
        total,
        items,
      } = body;

      if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
        return json({ error: "Missing payment verification fields" }, 400);
      }

      // ── 1. Verify signature ──────────────────────────────────────
      const expectedSig = await generateHmacSignature(
        `${razorpay_order_id}|${razorpay_payment_id}`,
        RAZORPAY_KEY_SECRET,
      );

      if (expectedSig !== razorpay_signature) {
        console.error("Signature mismatch", { expected: expectedSig, got: razorpay_signature });
        return json({ error: "Payment signature verification failed" }, 403);
      }

      // ── 2. Extract authenticated user from JWT ───────────────────
      const authHeader = req.headers.get("Authorization");
      if (!authHeader) return json({ error: "Unauthorized" }, 401);

      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
        global: { headers: { Authorization: authHeader } },
      });

      const {
        data: { user },
        error: userErr,
      } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));

      if (userErr || !user) return json({ error: "Invalid auth token" }, 401);

      // ── 3. Create order in DB ────────────────────────────────────
      const orderNumber = `PW-${Date.now()}`;
      const { data: orderRows, error: orderErr } = await supabase
        .from("orders")
        .insert({
          user_id: user.id,
          address_id,
          total_amount: total,
          status: "ordered",
          order_number: orderNumber,
          payment_method: "Razorpay",
          razorpay_payment_id,
        })
        .select();

      if (orderErr || !orderRows?.length) {
        console.error("Order insert error:", orderErr);
        return json({ error: "Failed to create order in database" }, 500);
      }

      const orderId = orderRows[0].id;

      // ── 4. Create order items ────────────────────────────────────
      const orderItems = (items as Array<{
        product_id: string;
        quantity: number;
        price_at_purchase: number;
      }>).map((i) => ({
        order_id: orderId,
        product_id: i.product_id,
        quantity: i.quantity,
        price_at_purchase: i.price_at_purchase,
      }));

      const { error: itemsErr } = await supabase.from("order_items").insert(orderItems);
      if (itemsErr) {
        console.error("Order items insert error:", itemsErr);
        // Non-fatal — order exists, items can be re-inserted by admin
      }

      // ── 5. Push to Shiprocket (non-fatal) ───────────────────────
      try {
        await supabase.functions.invoke("shiprocket-core/create", {
          body: { order_id: orderId },
        });
      } catch (srErr) {
        console.error("Shiprocket push error (non-fatal):", srErr);
      }

      return json({ success: true, order_number: orderNumber, order_id: orderId });
    } catch (err) {
      console.error("verify-payment exception:", err);
      return json({ error: String(err) }, 500);
    }
  }

  return json({ error: "Not found" }, 404);
});
