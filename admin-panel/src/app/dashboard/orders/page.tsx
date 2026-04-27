'use client';

import { useState } from 'react';
import { Download, Eye, Truck, Clock, CheckCircle, XCircle } from 'lucide-react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { useData } from '@/lib/data-context';
import { Order } from '@/lib/mock-data';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { toast } from 'sonner';

const ORDER_STATUSES = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'] as const;

const STATUS_CONFIG = {
  pending: {
    label: 'Pending',
    variant: 'secondary' as const,
    icon: Clock,
    color: 'text-yellow-600',
  },
  processing: {
    label: 'Processing',
    variant: 'secondary' as const,
    icon: Truck,
    color: 'text-blue-600',
  },
  shipped: {
    label: 'Shipped',
    variant: 'default' as const,
    icon: Truck,
    color: 'text-blue-600',
  },
  delivered: {
    label: 'Delivered',
    variant: 'default' as const,
    icon: CheckCircle,
    color: 'text-green-600',
  },
  cancelled: {
    label: 'Cancelled',
    variant: 'destructive' as const,
    icon: XCircle,
    color: 'text-red-600',
  },
};

export default function OrdersPage() {
  const { orders, updateOrderStatus, deleteOrder } = useData();
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [filter, setFilter] = useState<string>('all');

  const filteredOrders = filter === 'all'
    ? orders
    : orders.filter(o => o.status === filter);

  const pendingCount = orders.filter(o => o.status === 'pending').length;
  const processingCount = orders.filter(o => o.status === 'processing').length;
  const deliveredCount = orders.filter(o => o.status === 'delivered').length;

  const handleStatusChange = (orderId: string, newStatus: typeof ORDER_STATUSES[number]) => {
    updateOrderStatus(orderId, newStatus);
    toast.success(`Order status updated to ${STATUS_CONFIG[newStatus].label}`);
  };

  const handlePrint = (order: Order) => {
    toast.success(`Printing invoice for order ${order.orderNumber}`);
    window.print();
  };

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-slate-900">Orders</h1>
        <p className="text-slate-600 mt-2">Manage customer orders and track shipments</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pending Orders</CardTitle>
            <Clock className="h-4 w-4 text-yellow-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{pendingCount}</div>
            <p className="text-xs text-slate-600">Awaiting processing</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">In Transit</CardTitle>
            <Truck className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{processingCount}</div>
            <p className="text-xs text-slate-600">Currently processing</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Delivered</CardTitle>
            <CheckCircle className="h-4 w-4 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{deliveredCount}</div>
            <p className="text-xs text-slate-600">Successfully delivered</p>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Order List</CardTitle>
              <CardDescription>Total orders: {filteredOrders.length}</CardDescription>
            </div>
            <Select value={filter} onValueChange={setFilter}>
              <SelectTrigger className="w-40">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Orders</SelectItem>
                {ORDER_STATUSES.map((status) => (
                  <SelectItem key={status} value={status}>
                    {STATUS_CONFIG[status].label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Order Number</TableHead>
                  <TableHead>Customer</TableHead>
                  <TableHead>Total</TableHead>
                  <TableHead>Items</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredOrders.map((order) => {
                  const statusConfig = STATUS_CONFIG[order.status];
                  return (
                    <TableRow key={order.id}>
                      <TableCell className="font-medium">{order.orderNumber}</TableCell>
                      <TableCell>{order.customerName}</TableCell>
                      <TableCell>${order.total.toFixed(2)}</TableCell>
                      <TableCell>{order.items}</TableCell>
                      <TableCell>{new Date(order.date).toLocaleDateString()}</TableCell>
                      <TableCell>
                        <Badge variant={statusConfig.variant}>
                          {statusConfig.label}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => setSelectedOrder(order)}
                          >
                            <Eye className="w-4 h-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handlePrint(order)}
                          >
                            <Download className="w-4 h-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      {/* Order Details Modal */}
      {selectedOrder && (
        <Dialog open={!!selectedOrder} onOpenChange={() => setSelectedOrder(null)}>
          <DialogContent className="sm:max-w-[500px]">
            <DialogHeader>
              <DialogTitle>{selectedOrder.orderNumber}</DialogTitle>
              <DialogDescription>Order details and management</DialogDescription>
            </DialogHeader>

            <div className="space-y-6">
              {/* Order Info */}
              <div className="space-y-3">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-slate-600">Customer</p>
                    <p className="font-medium">{selectedOrder.customerName}</p>
                  </div>
                  <div>
                    <p className="text-sm text-slate-600">Total</p>
                    <p className="font-medium">${selectedOrder.total.toFixed(2)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-slate-600">Order Date</p>
                    <p className="font-medium">{new Date(selectedOrder.date).toLocaleDateString()}</p>
                  </div>
                  <div>
                    <p className="text-sm text-slate-600">Items</p>
                    <p className="font-medium">{selectedOrder.items}</p>
                  </div>
                </div>
              </div>

              {/* Status Update */}
              <div className="space-y-3 border-t pt-4">
                <p className="text-sm font-medium">Update Status</p>
                <Select
                  value={selectedOrder.status}
                  onValueChange={(value) => {
                    handleStatusChange(selectedOrder.id, value as typeof ORDER_STATUSES[number]);
                    setSelectedOrder({
                      ...selectedOrder,
                      status: value as typeof ORDER_STATUSES[number],
                    });
                  }}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {ORDER_STATUSES.map((status) => (
                      <SelectItem key={status} value={status}>
                        {STATUS_CONFIG[status].label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Actions */}
              <div className="flex gap-2 border-t pt-4">
                <Button
                  className="flex-1 gap-2"
                  variant="outline"
                  onClick={() => handlePrint(selectedOrder)}
                >
                  <Download className="w-4 h-4" />
                  Print Invoice
                </Button>
                <Button
                  className="flex-1"
                  variant="outline"
                  onClick={() => {
                    deleteOrder(selectedOrder.id);
                    setSelectedOrder(null);
                    toast.success('Order deleted');
                  }}
                >
                  Delete Order
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
