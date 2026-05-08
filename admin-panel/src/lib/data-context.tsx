'use client';

import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import { Product, Order, Customer, Coupon, Banner } from './mock-data';
import { supabase } from './supabase';
import { toast } from 'sonner';
import { inviteAdminAction } from '@/app/actions/admin';

interface DataContextType {
  // Products
  products: Product[];
  addProduct: (product: Omit<Product, 'id'>) => Promise<boolean>;
  updateProduct: (id: string, product: Partial<Product>) => Promise<boolean>;
  deleteProduct: (id: string) => Promise<void>;
  
  // Categories
  categories: { id: string, title: string }[];
  subCategories: { id: string, name: string, category_id: string }[];
  
  // Orders
  orders: Order[];
  addOrder: (order: Omit<Order, 'id'>) => Promise<void>;
  updateOrderStatus: (id: string, status: Order['status']) => Promise<void>;
  updateOrderShipping: (id: string, shipping: Partial<Pick<Order, 'trackingNumber' | 'shippingLabelUrl' | 'courierStatus'>>) => Promise<void>;
  deleteOrder: (id: string) => Promise<void>;
  
  // Customers
  customers: Customer[];
  admins: Customer[];
  addCustomer: (customer: Omit<Customer, 'id'>) => Promise<void>;
  updateCustomer: (id: string, customer: Partial<Customer>) => Promise<void>;
  deleteCustomer: (id: string) => Promise<void>;
  inviteAdmin: (email: string, name: string) => Promise<void>;
  revokeAdmin: (id: string) => Promise<void>;
  
  // Coupons
  coupons: Coupon[];
  addCoupon: (coupon: Omit<Coupon, 'id'>) => Promise<void>;
  updateCoupon: (id: string, coupon: Partial<Coupon>) => Promise<void>;
  deleteCoupon: (id: string) => Promise<void>;

  // Banners
  banners: Banner[];
  addBanner: (banner: Omit<Banner, 'id'>) => Promise<void>;
  updateBanner: (id: string, banner: Partial<Banner>) => Promise<void>;
  deleteBanner: (id: string) => Promise<void>;
  
  // Delivery Estimates
  deliveryEstimates: { id: string, pincode_prefix: string, min_days: number, max_days: number, description: string }[];
  addDeliveryEstimate: (estimate: { pincode_prefix: string, min_days: number, max_days: number, description: string }) => Promise<void>;
  updateDeliveryEstimate: (id: string, estimate: Partial<{ pincode_prefix: string, min_days: number, max_days: number, description: string }>) => Promise<void>;
  deleteDeliveryEstimate: (id: string) => Promise<void>;

  settings: Record<string, string>;
  updateSettings: (newSettings: Record<string, string>) => Promise<void>;
  
  loading: boolean;
  refreshData: () => Promise<void>;
}

const DataContext = createContext<DataContextType | undefined>(undefined);

export function DataProvider({ children }: { children: React.ReactNode }) {
  const [products, setProducts] = useState<Product[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [admins, setAdmins] = useState<Customer[]>([]);
  const [coupons, setCoupons] = useState<Coupon[]>([]);
  const [banners, setBanners] = useState<Banner[]>([]);
  const [categoriesList, setCategoriesList] = useState<{ id: string, title: string }[]>([]);
  const [subCategoriesList, setSubCategoriesList] = useState<{ id: string, name: string, category_id: string }[]>([]);
  const [settings, setSettings] = useState<Record<string, string>>({});
  const [deliveryEstimates, setDeliveryEstimates] = useState<{ id: string, pincode_prefix: string, min_days: number, max_days: number, description: string }[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async (isRefresh = false) => {
    if (!isRefresh) setLoading(true);
    console.log('Fetching dashboard data from Supabase...');
    try {
      const results = await Promise.allSettled([
        supabase.from('categories').select('*'),
        supabase.from('sub_categories').select('*'),
        supabase.from('products').select('*').order('created_at', { ascending: false }),
        supabase.from('orders').select('*, profiles(first_name, last_name), addresses(*), order_items(*, products(*))').order('created_at', { ascending: false }),
        supabase.from('profiles').select('*'),
        supabase.from('coupons').select('*').order('created_at', { ascending: false }),
        supabase.from('banners').select('*').order('created_at', { ascending: false }),
        supabase.from('settings').select('*'),
        supabase.from('delivery_estimates').select('*').order('pincode_prefix', { ascending: true })
      ]);

      // Check for failures in Promise.allSettled
      results.forEach((result, index) => {
        if (result.status === 'rejected') {
          console.error(`Query ${index} failed:`, result.reason);
        }
      });

      const [
        categoriesRes,
        subCategoriesRes,
        productsRes,
        ordersRes,
        profilesRes,
        couponsRes,
        bannersRes,
        settingsRes,
        deliveryEstimatesRes
      ] = results;

      const categoriesData = categoriesRes.status === 'fulfilled' ? categoriesRes.value.data : [];
      const subCategoriesData = subCategoriesRes.status === 'fulfilled' ? subCategoriesRes.value.data : [];
      const productsData = productsRes.status === 'fulfilled' ? productsRes.value.data : [];
      const ordersData = ordersRes.status === 'fulfilled' ? ordersRes.value.data : [];
      const profilesData = profilesRes.status === 'fulfilled' ? profilesRes.value.data : [];
      const couponsData = couponsRes.status === 'fulfilled' ? couponsRes.value.data : [];
      const bannersData = bannersRes.status === 'fulfilled' ? bannersRes.value.data : [];
      const settingsData = settingsRes.status === 'fulfilled' ? settingsRes.value.data : [];
      const deliveryEstimatesData = deliveryEstimatesRes.status === 'fulfilled' ? deliveryEstimatesRes.value.data : [];

      const cats = (categoriesData as any[])?.map(c => ({ id: c.id, title: c.title })) || [];
      setCategoriesList(cats);

      const subCats = (subCategoriesData as any[])?.map(sc => ({ id: sc.id, name: sc.name, category_id: sc.category_id })) || [];
      setSubCategoriesList(subCats);
      
      const categoryMap = cats.reduce((acc: any, cat: any) => {
        acc[cat.id] = cat.title;
        return acc;
      }, {}) || {};

      const subCategoryMap = subCats.reduce((acc: any, sc: any) => {
        acc[sc.id] = sc.name;
        return acc;
      }, {}) || {};

      setProducts((productsData as any[])?.map((p: any) => ({
        id: p.id,
        name: p.title,
        category: categoryMap[p.category_id] || 'Uncategorized',
        category_id: p.category_id,
        sub_category_id: p.sub_category_id,
        sub_category_name: subCategoryMap[p.sub_category_id] || '',
        price: Number(p.price),
        stock: p.stock_quantity,
        image: p.image_url,
        gallery: p.gallery_urls || [],
        description: p.description,
        discount_type: p.discount_type,
        discount_value: Number(p.discount_value),
        price_after_discount: Number(p.price_after_discount),
        discount_percent: p.discount_percent
      })) || []);

      setOrders((ordersData as any[])?.map((o: any) => ({
        id: o.id,
        orderNumber: o.order_number || `ORD-${o.id.slice(0, 8)}`,
        customerId: o.user_id,
        customerName: o.profiles ? `${(o.profiles as any).first_name} ${(o.profiles as any).last_name}` : 'Unknown Customer',
        total: o.total_amount,
        status: o.status.toLowerCase() as any,
        date: new Date(o.created_at).toISOString().split('T')[0],
        items: o.order_items?.length || 0,
        order_items: o.order_items || [],
        trackingNumber: o.tracking_number,
        shippingLabelUrl: o.shipping_label_url,
        courierStatus: o.courier_status,
        shiprocketOrderId: o.shiprocket_order_id,
        shipmentId: o.shipment_id,
        shippingAddress: o.addresses?.address,
        city: o.addresses?.city,
        state: o.addresses?.state,
        pincode: o.addresses?.pincode
      })) || []);

      const customersWithStats = (profilesData as any[])?.map((p: any) => {
        const customerOrders = (ordersData as any[] || []).filter((o: any) => o.user_id === p.id);
        const totalSpent = customerOrders.reduce((sum: number, o: any) => sum + o.total_amount, 0);
        
        return {
          id: p.id,
          name: `${p.first_name || ''} ${p.last_name || ''}`.trim() || 'No Name',
          email: 'N/A',
          phone: p.phone_number || 'N/A',
          totalOrders: customerOrders.length,
          totalSpent: totalSpent,
          joinDate: new Date(p.created_at).toISOString().split('T')[0],
          role: p.role || 'customer'
        };
      }) || [];
      
      setCustomers(customersWithStats.filter((c: any) => c.role === 'customer'));
      setAdmins(customersWithStats.filter((c: any) => c.role === 'admin'));

      setCoupons((couponsData as any[])?.map((c: any) => ({
        id: c.id,
        code: c.code,
        discount: c.discount,
        type: c.type as any,
        expiry: new Date(c.expiry).toISOString().split('T')[0],
        active: c.active
      })) || []);

      setBanners((bannersData as any[])?.map((b: any) => ({
        id: b.id,
        imageUrl: b.image_url,
        title: b.title,
        linkTo: b.link_to,
        active: b.active
      })) || []);
      
      const settingsObj = (settingsData as any[])?.reduce((acc: any, s: any) => {
        acc[s.key] = s.value;
        return acc;
      }, {}) || {};
      setSettings(settingsObj);
      setDeliveryEstimates(deliveryEstimatesData || []);

      console.log('Dashboard data fetched successfully.');
    } catch (error) {
      console.error('Unexpected error fetching dashboard data:', error);
      toast.error('Unable to load some dashboard information.');
    } finally {
      setLoading(false);
    }
  }, []);

  const refreshData = useCallback(async () => {
    await fetchData(true);
  }, [fetchData]);

  useEffect(() => {
    fetchData();

    // Subscribe to new orders
    const channel = supabase
      .channel('public:orders')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'orders',
        },
        (payload) => {
          console.log('New order received via Realtime:', payload);
          toast.success('New Order Received!', {
            description: `Order #${payload.new.order_number} has been placed.`,
            action: {
              label: 'Refresh',
              onClick: () => fetchData(true)
            }
          });
          fetchData(true);
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [fetchData]);

  const addProduct = async (product: Omit<Product, 'id'>): Promise<boolean> => {
    try {
      console.log('Adding product:', product);
      const categoryId = (product.category_id && product.category_id !== '') 
        ? product.category_id 
        : (categoriesList.find(c => c.title === product.category)?.id || null);

      let priceAfterDiscount = product.price;
      let discountPercent = 0;

      if (product.discount_type === 'percentage') {
        discountPercent = Math.round(product.discount_value || 0);
        priceAfterDiscount = Number((product.price * (1 - discountPercent / 100)).toFixed(2));
      } else if (product.discount_type === 'fixed') {
        const discountVal = product.discount_value || 0;
        priceAfterDiscount = Math.max(0, Number((product.price - discountVal).toFixed(2)));
        discountPercent = product.price > 0 ? Math.round(((product.price - priceAfterDiscount) / product.price) * 100) : 0;
      }

      const { data, error } = await supabase.from('products').insert({
        title: product.name,
        category_id: categoryId,
        sub_category_id: (product.sub_category_id && product.sub_category_id !== '') ? product.sub_category_id : null,
        price: product.price,
        image_url: product.image,
        description: product.description,
        stock_quantity: product.stock,
        discount_type: product.discount_type || null,
        discount_value: product.discount_value || 0,
        price_after_discount: priceAfterDiscount,
        discount_percent: discountPercent,
        gallery_urls: product.gallery && product.gallery.length > 0 ? product.gallery : [product.image],
        weight: product.weight || 0.5,
        length: product.length || 10,
        width: product.width || 10,
        height: product.height || 10,
      }).select();

      if (error) {
        console.error('Supabase insert error:', error);
        toast.error(error.message);
        return false;
      }

      toast.success('Product added successfully');
      refreshData();
      return true;
    } catch (err: any) {
      console.error('Unexpected error in addProduct:', err);
      toast.error('An unexpected error occurred while saving');
      return false;
    }
  };

  const updateProduct = async (id: string, product: Partial<Product>): Promise<boolean> => {
    try {
      console.log('Updating product:', id, product);
      const currentProduct = products.find(p => p.id === id);
      const pPrice = product.price ?? currentProduct?.price ?? 0;
      const pType = product.discount_type !== undefined ? product.discount_type : (currentProduct?.discount_type ?? null);
      const pValue = product.discount_value !== undefined ? product.discount_value : (currentProduct?.discount_value ?? 0);

      let priceAfterDiscount = pPrice;
      let discountPercent = 0;

      if (pType === 'percentage') {
        discountPercent = Math.round(pValue);
        priceAfterDiscount = Number((pPrice * (1 - discountPercent / 100)).toFixed(2));
      } else if (pType === 'fixed') {
        priceAfterDiscount = Math.max(0, Number((pPrice - pValue).toFixed(2)));
        discountPercent = pPrice > 0 ? Math.round(((pPrice - priceAfterDiscount) / pPrice) * 100) : 0;
      }

      const updateData: any = {
        ...(product.name && { title: product.name }),
        ...(product.price !== undefined && { price: product.price }),
        ...(product.stock !== undefined && { stock_quantity: product.stock }),
        ...(product.image && { image_url: product.image }),
        ...(product.gallery && { gallery_urls: product.gallery }),
        ...(product.description !== undefined && { description: product.description }),
        ...(product.category_id !== undefined && { category_id: product.category_id || null }),
        ...(product.sub_category_id !== undefined && { sub_category_id: product.sub_category_id || null }),
        discount_type: pType,
        discount_value: pValue,
        price_after_discount: priceAfterDiscount,
        discount_percent: discountPercent,
        ...(product.weight !== undefined && { weight: product.weight }),
        ...(product.length !== undefined && { length: product.length }),
        ...(product.width !== undefined && { width: product.width }),
        ...(product.height !== undefined && { height: product.height }),
      };

      const { error } = await supabase.from('products').update(updateData).eq('id', id);

      if (error) {
        console.error('Supabase update error:', error);
        toast.error(error.message);
        return false;
      }

      toast.success('Product updated successfully');
      refreshData();
      return true;
    } catch (err: any) {
      console.error('Unexpected error in updateProduct:', err);
      toast.error('An unexpected error occurred while updating');
      return false;
    }
  };

  const deleteProduct = async (id: string) => {
    const { error } = await supabase.from('products').delete().eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Product deleted');
      refreshData();
    }
  };

  // Order management
  const addOrder = async (order: Omit<Order, 'id'>) => {
    // In a real app, this would involve multiple tables
    toast.info('Order creation not implemented for Admin Panel');
  };

  const updateOrderStatus = async (id: string, status: Order['status']) => {
    const { error } = await supabase.from('orders').update({
      status: status
    }).eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Order status updated');
      refreshData();
    }
  };

  const updateOrderShipping = async (id: string, shipping: Partial<Pick<Order, 'trackingNumber' | 'shippingLabelUrl' | 'courierStatus' | 'shiprocketOrderId' | 'shipmentId'>>) => {
    const { error } = await supabase.from('orders').update({
      tracking_number: shipping.trackingNumber,
      shipping_label_url: shipping.shippingLabelUrl,
      courier_status: shipping.courierStatus,
      shiprocket_order_id: shipping.shiprocketOrderId,
      shipment_id: shipping.shipmentId
    }).eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Shipping information updated');
      refreshData();
    }
  };

  const deleteOrder = async (id: string) => {
    const { error } = await supabase.from('orders').delete().eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Order deleted');
      refreshData();
    }
  };

  // Customer management
  const addCustomer = async (customer: Omit<Customer, 'id'>) => {
    toast.info('Customer creation usually happens via Auth');
  };

  const updateCustomer = async (id: string, customer: Partial<Customer>) => {
    const [firstName, ...lastNames] = (customer.name || '').split(' ');
    const { error } = await supabase.from('profiles').update({
      first_name: firstName,
      last_name: lastNames.join(' '),
      phone_number: customer.phone
    }).eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Customer updated');
      fetchData();
    }
  };

  const deleteCustomer = async (id: string) => {
    const { error } = await supabase.from('profiles').delete().eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Customer deleted');
      fetchData();
    }
  };

  const inviteAdmin = async (email: string, name: string) => {
    try {
      await inviteAdminAction(email, name);
      toast.success(`Invitation sent to ${email}`);
      fetchData(); // Refresh list to show new (pending) user if possible
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Failed to send invitation');
      throw error;
    }
  };

  const revokeAdmin = async (id: string) => {
    const { error } = await supabase.from('profiles').update({
      role: 'customer'
    }).eq('id', id);
    
    if (error) toast.error(error.message);
    else {
      toast.success('Admin access revoked');
      fetchData();
    }
  };

  // Coupon management
  const addCoupon = async (coupon: Omit<Coupon, 'id'>) => {
    const { error } = await supabase.from('coupons').insert({
      code: coupon.code,
      discount: coupon.discount,
      type: coupon.type,
      expiry: coupon.expiry,
      active: coupon.active
    });
    if (error) toast.error(error.message);
    else {
      toast.success('Coupon created');
      fetchData();
    }
  };

  const updateCoupon = async (id: string, coupon: Partial<Coupon>) => {
    const { error } = await supabase.from('coupons').update({
      code: coupon.code,
      discount: coupon.discount,
      type: coupon.type,
      expiry: coupon.expiry,
      active: coupon.active
    }).eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Coupon updated');
      fetchData();
    }
  };

  const deleteCoupon = async (id: string) => {
    const { error } = await supabase.from('coupons').delete().eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Coupon deleted');
      fetchData();
    }
  };

  // Banner management
  const addBanner = async (banner: Omit<Banner, 'id'>) => {
    const { error } = await supabase.from('banners').insert({
      image_url: banner.imageUrl,
      title: banner.title,
      link_to: banner.linkTo,
      active: banner.active
    });
    if (error) toast.error(error.message);
    else {
      toast.success('Banner added');
      fetchData();
    }
  };

  const updateBanner = async (id: string, banner: Partial<Banner>) => {
    const { error } = await supabase.from('banners').update({
      image_url: banner.imageUrl,
      title: banner.title,
      link_to: banner.linkTo,
      active: banner.active
    }).eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Banner updated');
      fetchData();
    }
  };

  const deleteBanner = async (id: string) => {
    const { error } = await supabase.from('banners').delete().eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Banner deleted');
      fetchData();
    }
  };

  const updateSettings = async (newSettings: Record<string, string>) => {
    try {
      const updates = Object.entries(newSettings).map(([key, value]) => ({
        key,
        value
      }));

      const { error } = await supabase.from('settings').upsert(updates, { onConflict: 'key' });
      
      if (error) throw error;
      
      toast.success('Settings updated successfully');
      setSettings(prev => ({ ...prev, ...newSettings }));
    } catch (error: any) {
      console.error('Error updating settings:', error);
      toast.error(error.message || 'Failed to update settings');
    }
  };

  const addDeliveryEstimate = async (estimate: { pincode_prefix: string, min_days: number, max_days: number, description: string }) => {
    const { error } = await supabase.from('delivery_estimates').insert(estimate);
    if (error) toast.error(error.message);
    else {
      toast.success('Delivery estimate added');
      fetchData();
    }
  };

  const updateDeliveryEstimate = async (id: string, estimate: Partial<{ pincode_prefix: string, min_days: number, max_days: number, description: string }>) => {
    const { error } = await supabase.from('delivery_estimates').update(estimate).eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Delivery estimate updated');
      fetchData();
    }
  };

  const deleteDeliveryEstimate = async (id: string) => {
    const { error } = await supabase.from('delivery_estimates').delete().eq('id', id);
    if (error) toast.error(error.message);
    else {
      toast.success('Delivery estimate deleted');
      fetchData();
    }
  };

  return (
    <DataContext.Provider value={{
      products,
      addProduct,
      updateProduct,
      deleteProduct,
      orders,
      addOrder,
      updateOrderStatus,
      updateOrderShipping,
      deleteOrder,
      customers,
      admins,
      addCustomer,
      updateCustomer,
      deleteCustomer,
      inviteAdmin,
      revokeAdmin,
      coupons,
      addCoupon,
      updateCoupon,
      deleteCoupon,
      banners,
      addBanner,
      updateBanner,
      deleteBanner,
      settings,
      updateSettings,
      deliveryEstimates,
      addDeliveryEstimate,
      updateDeliveryEstimate,
      deleteDeliveryEstimate,
      categories: categoriesList,
      subCategories: subCategoriesList,
      loading,
      refreshData: fetchData
    }}>
      {children}
    </DataContext.Provider>
  );
}

export function useData() {
  const context = useContext(DataContext);
  if (!context) {
    throw new Error('useData must be used within DataProvider');
  }
  return context;
}
