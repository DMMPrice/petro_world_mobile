'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Product } from '@/lib/mock-data';
import { useData } from '@/lib/data-context';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { toast } from 'sonner';

const productSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  category: z.string().min(1, 'Category is required'),
  price: z.coerce.number().min(0, 'Price must be positive'),
  stock: z.coerce.number().min(0, 'Stock must be non-negative'),
  sku: z.string().min(1, 'SKU is required'),
});

type ProductFormData = z.infer<typeof productSchema>;

const CATEGORIES = [
  'Fuel',
  'Gas',
  'Lubricants',
  'Maintenance',
  'Detailing',
  'Accessories',
];

interface ProductFormProps {
  product?: Product;
  onClose: () => void;
}

export function ProductForm({ product, onClose }: ProductFormProps) {
  const { addProduct, updateProduct } = useData();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
  } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
    defaultValues: product || {
      name: '',
      category: 'Fuel',
      price: 0,
      stock: 0,
      sku: '',
    },
  });

  const selectedCategory = watch('category');

  const onSubmit = async (data: ProductFormData) => {
    setIsSubmitting(true);
    try {
      if (product) {
        updateProduct(product.id, data);
        toast.success('Product updated successfully');
      } else {
        addProduct(data);
        toast.success('Product added successfully');
      }
      onClose();
    } catch (error) {
      toast.error('Failed to save product');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open={true} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{product ? 'Edit Product' : 'Add New Product'}</DialogTitle>
          <DialogDescription>
            {product ? 'Update the product details' : 'Add a new product to your catalog'}
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="name">Product Name</Label>
            <Input
              id="name"
              placeholder="e.g., Unleaded 95"
              {...register('name')}
            />
            {errors.name && <p className="text-sm text-red-600">{errors.name.message}</p>}
          </div>

          <div className="space-y-2">
            <Label htmlFor="sku">SKU</Label>
            <Input
              id="sku"
              placeholder="e.g., FUEL-95-001"
              {...register('sku')}
            />
            {errors.sku && <p className="text-sm text-red-600">{errors.sku.message}</p>}
          </div>

          <div className="space-y-2">
            <Label htmlFor="category">Category</Label>
            <Select
              value={selectedCategory}
              onValueChange={(value) => setValue('category', value)}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {CATEGORIES.map((cat) => (
                  <SelectItem key={cat} value={cat}>
                    {cat}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {errors.category && <p className="text-sm text-red-600">{errors.category.message}</p>}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="price">Price ($)</Label>
              <Input
                id="price"
                type="number"
                step="0.01"
                placeholder="0.00"
                {...register('price')}
              />
              {errors.price && <p className="text-sm text-red-600">{errors.price.message}</p>}
            </div>

            <div className="space-y-2">
              <Label htmlFor="stock">Stock</Label>
              <Input
                id="stock"
                type="number"
                placeholder="0"
                {...register('stock')}
              />
              {errors.stock && <p className="text-sm text-red-600">{errors.stock.message}</p>}
            </div>
          </div>

          <div className="flex justify-end gap-2 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              className="bg-amber-500 hover:bg-amber-600"
              disabled={isSubmitting}
            >
              {isSubmitting ? 'Saving...' : 'Save Product'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
