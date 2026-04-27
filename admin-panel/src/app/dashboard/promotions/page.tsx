'use client';

import { useState } from 'react';
import { Plus, Copy, Trash2, Toggle2 } from 'lucide-react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { useData } from '@/lib/data-context';
import { Coupon } from '@/lib/mock-data';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useForm } from 'react-hook-form';
import { toast } from 'sonner';

export default function PromotionsPage() {
  const { coupons, addCoupon, deleteCoupon, updateCoupon } = useData();
  const [isFormOpen, setIsFormOpen] = useState(false);

  const activeCoupons = coupons.filter(c => c.active).length;
  const totalDiscount = coupons.reduce((sum, c) => sum + c.discount, 0);

  const handleToggle = (coupon: Coupon) => {
    updateCoupon(coupon.id, { active: !coupon.active });
    toast.success(`Coupon ${coupon.active ? 'deactivated' : 'activated'}`);
  };

  const handleCopy = (code: string) => {
    navigator.clipboard.writeText(code);
    toast.success('Code copied to clipboard');
  };

  const isExpired = (expiry: string) => new Date(expiry) < new Date();

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Promotions</h1>
          <p className="text-slate-600 mt-2">Manage coupons and discount offers</p>
        </div>
        <Button
          onClick={() => setIsFormOpen(true)}
          className="gap-2 bg-amber-500 hover:bg-amber-600"
        >
          <Plus className="w-4 h-4" />
          New Coupon
        </Button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Coupons</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{activeCoupons}</div>
            <p className="text-xs text-slate-600">Currently active</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Coupons</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{coupons.length}</div>
            <p className="text-xs text-slate-600">All time</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Combined Discount</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{totalDiscount}%</div>
            <p className="text-xs text-slate-600">Average value</p>
          </CardContent>
        </Card>
      </div>

      {/* Featured Offers Carousel */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Featured Offers</CardTitle>
          <CardDescription>Current active promotions</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {coupons.filter(c => c.active && !isExpired(c.expiry)).map((coupon) => (
              <div
                key={coupon.id}
                className="border border-amber-200 bg-amber-50 rounded-lg p-4 space-y-3"
              >
                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <p className="text-2xl font-bold text-amber-600">
                      {coupon.discount}{coupon.type === 'percentage' ? '%' : '$'}
                    </p>
                    <p className="text-sm text-slate-600">
                      {coupon.type === 'percentage' ? 'Discount' : 'Off'}
                    </p>
                  </div>
                  <Badge className="bg-green-100 text-green-800 hover:bg-green-200">
                    Active
                  </Badge>
                </div>
                <div className="space-y-2">
                  <div>
                    <p className="text-xs text-slate-600">Code</p>
                    <p className="font-mono font-bold">{coupon.code}</p>
                  </div>
                  <p className="text-xs text-slate-600">
                    Expires: {new Date(coupon.expiry).toLocaleDateString()}
                  </p>
                </div>
                <Button
                  size="sm"
                  variant="outline"
                  className="w-full gap-1"
                  onClick={() => handleCopy(coupon.code)}
                >
                  <Copy className="w-3 h-3" />
                  Copy Code
                </Button>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Coupons Table */}
      <Card>
        <CardHeader>
          <CardTitle>All Coupons</CardTitle>
          <CardDescription>Manage all promotional codes and discounts</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Code</TableHead>
                  <TableHead>Discount</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Expires</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {coupons.map((coupon) => {
                  const expired = isExpired(coupon.expiry);
                  return (
                    <TableRow key={coupon.id}>
                      <TableCell className="font-mono font-bold">{coupon.code}</TableCell>
                      <TableCell>
                        <span className="font-semibold">
                          {coupon.discount}{coupon.type === 'percentage' ? '%' : '$'}
                        </span>
                      </TableCell>
                      <TableCell>
                        <Badge variant="secondary">
                          {coupon.type === 'percentage' ? 'Percentage' : 'Fixed'}
                        </Badge>
                      </TableCell>
                      <TableCell>{new Date(coupon.expiry).toLocaleDateString()}</TableCell>
                      <TableCell>
                        {expired ? (
                          <Badge variant="destructive">Expired</Badge>
                        ) : coupon.active ? (
                          <Badge className="bg-green-100 text-green-800 hover:bg-green-200">
                            Active
                          </Badge>
                        ) : (
                          <Badge variant="secondary">Inactive</Badge>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-2">
                          {!expired && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleToggle(coupon)}
                              className={coupon.active ? 'text-green-600' : 'text-slate-400'}
                            >
                              <Toggle2 className="w-4 h-4" />
                            </Button>
                          )}
                          <AlertDialog>
                            <AlertDialogTrigger asChild>
                              <Button
                                variant="ghost"
                                size="sm"
                                className="text-red-600 hover:text-red-700 hover:bg-red-50"
                              >
                                <Trash2 className="w-4 h-4" />
                              </Button>
                            </AlertDialogTrigger>
                            <AlertDialogContent>
                              <AlertDialogTitle>Delete Coupon</AlertDialogTitle>
                              <AlertDialogDescription>
                                Are you sure you want to delete coupon {coupon.code}? This action cannot be undone.
                              </AlertDialogDescription>
                              <div className="flex justify-end gap-2">
                                <AlertDialogCancel>Cancel</AlertDialogCancel>
                                <AlertDialogAction
                                  onClick={() => deleteCoupon(coupon.id)}
                                  className="bg-red-600 hover:bg-red-700"
                                >
                                  Delete
                                </AlertDialogAction>
                              </div>
                            </AlertDialogContent>
                          </AlertDialog>
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

      {/* Add Coupon Form */}
      {isFormOpen && (
        <AddCouponDialog onClose={() => setIsFormOpen(false)} />
      )}
    </div>
  );
}

function AddCouponDialog({ onClose }: { onClose: () => void }) {
  const { addCoupon } = useData();
  const [type, setType] = useState<'percentage' | 'fixed'>('percentage');
  const { register, handleSubmit, reset, formState: { errors } } = useForm({
    defaultValues: {
      code: '',
      discount: 0,
      expiry: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    },
  });

  const onSubmit = (data: any) => {
    addCoupon({
      code: data.code.toUpperCase(),
      discount: parseInt(data.discount),
      type,
      expiry: data.expiry,
      active: true,
    });
    toast.success('Coupon created successfully');
    reset();
    onClose();
  };

  return (
    <Dialog open={true} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Create New Coupon</DialogTitle>
          <DialogDescription>Add a new promotional discount code</DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="code">Coupon Code</Label>
            <Input
              id="code"
              placeholder="SAVE10"
              {...register('code', { required: 'Code is required' })}
            />
            {errors.code && <p className="text-sm text-red-600">{errors.code.message}</p>}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="discount">Discount Value</Label>
              <Input
                id="discount"
                type="number"
                placeholder="10"
                {...register('discount', { required: 'Discount is required' })}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="type">Type</Label>
              <Select value={type} onValueChange={(val) => setType(val as 'percentage' | 'fixed')}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="percentage">Percentage (%)</SelectItem>
                  <SelectItem value="fixed">Fixed ($)</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="expiry">Expiry Date</Label>
            <Input
              id="expiry"
              type="date"
              {...register('expiry', { required: 'Expiry date is required' })}
            />
          </div>

          <div className="flex justify-end gap-2 pt-4">
            <Button variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" className="bg-amber-500 hover:bg-amber-600">
              Create Coupon
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
