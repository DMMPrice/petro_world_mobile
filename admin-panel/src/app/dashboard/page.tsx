'use client';

import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { DollarSign, ShoppingCart, Users, TrendingUp } from 'lucide-react';
import { mockAnalytics, mockChartData } from '@/lib/mock-data';
import { useData } from '@/lib/data-context';
import { Badge } from '@/components/ui/badge';

export default function DashboardPage() {
  const { orders, products } = useData();
  
  const lowStockCount = products.filter(p => p.stock < 100).length;
  const pendingOrders = orders.filter(o => o.status === 'pending').length;

  return (
    <div className="p-8 space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-slate-900">Dashboard</h1>
        <p className="text-slate-600 mt-2">Welcome to PetroWorld Admin Panel</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
            <DollarSign className="h-4 w-4 text-slate-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">${mockAnalytics.totalRevenue.toLocaleString('en-US', { minimumFractionDigits: 2 })}</div>
            <p className="text-xs text-slate-600">+12% from last month</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Orders</CardTitle>
            <ShoppingCart className="h-4 w-4 text-slate-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{mockAnalytics.totalOrders}</div>
            <p className="text-xs text-slate-600">{pendingOrders} pending orders</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Customers</CardTitle>
            <Users className="h-4 w-4 text-slate-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{mockAnalytics.totalCustomers}</div>
            <p className="text-xs text-slate-600">+8 this month</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Avg Order Value</CardTitle>
            <TrendingUp className="h-4 w-4 text-slate-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">${mockAnalytics.averageOrderValue.toFixed(2)}</div>
            <p className="text-xs text-slate-600">Across all orders</p>
          </CardContent>
        </Card>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Revenue Trend</CardTitle>
            <CardDescription>Monthly revenue over the last 6 months</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={mockChartData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="revenue" stroke="#f59e0b" />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Order Volume</CardTitle>
            <CardDescription>Monthly order count over the last 6 months</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={mockChartData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="orders" fill="#f59e0b" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Inventory Alerts</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {lowStockCount > 0 ? (
                <>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-slate-600">Low stock items</span>
                    <Badge variant="destructive">{lowStockCount}</Badge>
                  </div>
                  <p className="text-xs text-slate-500">
                    {lowStockCount} products have stock below 100 units. Consider reordering soon.
                  </p>
                </>
              ) : (
                <p className="text-sm text-slate-600">All inventory levels are healthy!</p>
              )}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Pending Orders</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {pendingOrders > 0 ? (
                <>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-slate-600">Orders awaiting processing</span>
                    <Badge>{pendingOrders}</Badge>
                  </div>
                  <p className="text-xs text-slate-500">
                    {pendingOrders} order(s) need attention. Visit the Orders page to process them.
                  </p>
                </>
              ) : (
                <p className="text-sm text-slate-600">No pending orders at the moment!</p>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
