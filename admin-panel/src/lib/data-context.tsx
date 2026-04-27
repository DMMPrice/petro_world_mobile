'use client';

import React, { createContext, useContext, useState, useCallback } from 'react';
import { Product, Order, Customer, Coupon, mockProducts, mockOrders, mockCustomers, mockCoupons } from './mock-data';

interface DataContextType {
  // Products
  products: Product[];
  addProduct: (product: Omit<Product, 'id'>) => void;
  updateProduct: (id: string, product: Partial<Product>) => void;
  deleteProduct: (id: string) => void;
  
  // Orders
  orders: Order[];
  addOrder: (order: Omit<Order, 'id'>) => void;
  updateOrderStatus: (id: string, status: Order['status']) => void;
  deleteOrder: (id: string) => void;
  
  // Customers
  customers: Customer[];
  addCustomer: (customer: Omit<Customer, 'id'>) => void;
  updateCustomer: (id: string, customer: Partial<Customer>) => void;
  deleteCustomer: (id: string) => void;
  
  // Coupons
  coupons: Coupon[];
  addCoupon: (coupon: Omit<Coupon, 'id'>) => void;
  updateCoupon: (id: string, coupon: Partial<Coupon>) => void;
  deleteCoupon: (id: string) => void;
}

const DataContext = createContext<DataContextType | undefined>(undefined);

export function DataProvider({ children }: { children: React.ReactNode }) {
  const [products, setProducts] = useState<Product[]>(mockProducts);
  const [orders, setOrders] = useState<Order[]>(mockOrders);
  const [customers, setCustomers] = useState<Customer[]>(mockCustomers);
  const [coupons, setCoupons] = useState<Coupon[]>(mockCoupons);

  // Product management
  const addProduct = useCallback((product: Omit<Product, 'id'>) => {
    const id = String(Math.max(...products.map(p => parseInt(p.id) || 0), 0) + 1);
    setProducts(prev => [...prev, { ...product, id }]);
  }, [products]);

  const updateProduct = useCallback((id: string, product: Partial<Product>) => {
    setProducts(prev => prev.map(p => p.id === id ? { ...p, ...product } : p));
  }, []);

  const deleteProduct = useCallback((id: string) => {
    setProducts(prev => prev.filter(p => p.id !== id));
  }, []);

  // Order management
  const addOrder = useCallback((order: Omit<Order, 'id'>) => {
    const id = String(Math.max(...orders.map(o => parseInt(o.id) || 0), 0) + 1);
    setOrders(prev => [...prev, { ...order, id }]);
  }, [orders]);

  const updateOrderStatus = useCallback((id: string, status: Order['status']) => {
    setOrders(prev => prev.map(o => o.id === id ? { ...o, status } : o));
  }, []);

  const deleteOrder = useCallback((id: string) => {
    setOrders(prev => prev.filter(o => o.id !== id));
  }, []);

  // Customer management
  const addCustomer = useCallback((customer: Omit<Customer, 'id'>) => {
    const id = String(Math.max(...customers.map(c => parseInt(c.id.slice(1)) || 0), 0) + 1);
    setCustomers(prev => [...prev, { ...customer, id: `c${id}` }]);
  }, [customers]);

  const updateCustomer = useCallback((id: string, customer: Partial<Customer>) => {
    setCustomers(prev => prev.map(c => c.id === id ? { ...c, ...customer } : c));
  }, []);

  const deleteCustomer = useCallback((id: string) => {
    setCustomers(prev => prev.filter(c => c.id !== id));
  }, []);

  // Coupon management
  const addCoupon = useCallback((coupon: Omit<Coupon, 'id'>) => {
    const id = String(Math.max(...coupons.map(c => parseInt(c.id) || 0), 0) + 1);
    setCoupons(prev => [...prev, { ...coupon, id }]);
  }, [coupons]);

  const updateCoupon = useCallback((id: string, coupon: Partial<Coupon>) => {
    setCoupons(prev => prev.map(c => c.id === id ? { ...c, ...coupon } : c));
  }, []);

  const deleteCoupon = useCallback((id: string) => {
    setCoupons(prev => prev.filter(c => c.id !== id));
  }, []);

  return (
    <DataContext.Provider value={{
      products,
      addProduct,
      updateProduct,
      deleteProduct,
      orders,
      addOrder,
      updateOrderStatus,
      deleteOrder,
      customers,
      addCustomer,
      updateCustomer,
      deleteCustomer,
      coupons,
      addCoupon,
      updateCoupon,
      deleteCoupon,
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
