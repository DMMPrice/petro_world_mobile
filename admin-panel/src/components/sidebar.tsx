'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  BarChart3,
  Package,
  ShoppingCart,
  Users,
  Gauge,
  Tag,
  LogOut,
  Menu,
  ShieldCheck,
  Settings,
  HelpCircle,
  MessageSquare,
} from 'lucide-react';
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import { useAuth } from '@/lib/auth-context';

const navigationItems = [
  {
    title: 'Dashboard',
    href: '/dashboard',
    icon: BarChart3,
  },
  {
    title: 'Products',
    href: '/dashboard/products',
    icon: Package,
  },
  {
    title: 'Orders',
    href: '/dashboard/orders',
    icon: ShoppingCart,
  },
  {
    title: 'Inventory',
    href: '/dashboard/inventory',
    icon: Gauge,
  },
  {
    title: 'Customers',
    href: '/dashboard/customers',
    icon: Users,
  },
  {
    title: 'Promotions',
    href: '/dashboard/promotions',
    icon: Tag,
  },
  {
    title: 'Team',
    href: '/dashboard/team',
    icon: ShieldCheck,
  },
  {
    title: 'FAQs',
    href: '/dashboard/faqs',
    icon: HelpCircle,
  },
  {
    title: 'Support',
    href: '/dashboard/support',
    icon: MessageSquare,
  },
  {
    title: 'Settings',
    href: '/dashboard/settings',
    icon: Settings,
  },
];

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const { logout, user } = useAuth();
  const [open, setOpen] = useState(true);

  const handleLogout = () => {
    logout();
    router.push('/login');
  };

  return (
    <>
      <aside
        className={cn(
          'fixed left-0 top-0 h-screen bg-slate-900 border-r border-slate-800 transition-all duration-300 z-40',
          open ? 'w-64' : 'w-20'
        )}
      >
        {/* Header */}
        <div className="h-16 flex items-center justify-between px-4 border-b border-slate-800">
          {open && (
            <div className="flex items-center gap-2">
              <img src="/logo.png" alt="PETRO WORLD Logo" className="w-10 h-10 object-contain" />
              <span className="font-bold text-white text-lg">PETRO WORLD</span>
            </div>
          )}
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setOpen(!open)}
            className="text-slate-400 hover:text-white hover:bg-slate-800"
          >
            <Menu className="w-5 h-5" />
          </Button>
        </div>

        {/* Navigation */}
        <nav className="p-4 space-y-2">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href || pathname.startsWith(item.href + '/');
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex items-center gap-3 px-4 py-3 rounded-lg transition-colors',
                  isActive
                    ? 'bg-[#F57C00] text-white'
                    : 'text-slate-400 hover:text-white hover:bg-slate-800'
                )}
              >
                <Icon className="w-5 h-5 flex-shrink-0" />
                {open && <span className="text-sm font-medium">{item.title}</span>}
              </Link>
            );
          })}
        </nav>

        {/* Footer */}
        <div className="absolute bottom-4 left-4 right-4 border-t border-slate-800 pt-4">
          {open && user && (
            <p className="text-xs text-slate-400 mb-3 px-2">
              Logged in as <span className="font-semibold">{user.name}</span>
            </p>
          )}
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-colors text-sm"
          >
            <LogOut className="w-5 h-5 flex-shrink-0" />
            {open && <span>Logout</span>}
          </button>
        </div>
      </aside>

      {/* Main content offset */}
      <div className={cn('transition-all duration-300', open ? 'ml-64' : 'ml-20')} />
    </>
  );
}
