'use server';

import { createClient } from '@supabase/supabase-js';

export async function inviteAdminAction(email: string, name: string) {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error('Missing Supabase configuration. Please check your environment variables.');
  }

  const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  });

  const [firstName, ...lastNames] = name.split(' ');

  // 1. Send the invitation
  const { data, error } = await supabaseAdmin.auth.admin.inviteUserByEmail(email, {
    data: {
      first_name: firstName,
      last_name: lastNames.join(' '),
    },
    redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3001'}/login`
  });

  if (error) {
    console.error('Invite error:', error);
    throw new Error(error.message);
  }

  // 2. Update the profile role to 'admin'
  // The trigger 'on_auth_user_created' creates the profile immediately on invitation.
  if (data.user) {
    const { error: profileError } = await supabaseAdmin
      .from('profiles')
      .update({ role: 'admin' })
      .eq('id', data.user.id);
      
    if (profileError) {
      console.error('Profile update error:', profileError);
      // Even if this fails, the user is invited. 
      // The admin can manually change the role in the "Team" table if needed.
    }
  }

  return { success: true };
}
