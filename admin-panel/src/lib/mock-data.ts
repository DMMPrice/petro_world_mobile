// Mock data for the PetroWorld Admin Panel
export interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  stock: number;
  sku: string;
  image?: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerId: string;
  customerName: string;
  total: number;
  status: 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  date: string;
  items: number;
}

export interface Customer {
  id: string;
  name: string;
  email: string;
  phone: string;
  totalOrders: number;
  totalSpent: number;
  joinDate: string;
}

export interface Coupon {
  id: string;
  code: string;
  discount: number;
  type: 'percentage' | 'fixed';
  expiry: string;
  active: boolean;
}

export const mockProducts: Product[] = [
  {
    id: '1',
    name: 'Unleaded 95',
    category: 'Fuel',
    price: 2.45,
    stock: 5000,
    sku: 'FUEL-95-001',
  },
  {
    id: '2',
    name: 'Unleaded 98',
    category: 'Fuel',
    price: 2.65,
    stock: 3200,
    sku: 'FUEL-98-001',
  },
  {
    id: '3',
    name: 'Diesel',
    category: 'Fuel',
    price: 2.35,
    stock: 4500,
    sku: 'DIESEL-001',
  },
  {
    id: '4',
    name: 'LPG',
    category: 'Gas',
    price: 1.85,
    stock: 2000,
    sku: 'LPG-001',
  },
  {
    id: '5',
    name: 'Motor Oil 5W-30',
    category: 'Lubricants',
    price: 8.99,
    stock: 450,
    sku: 'OIL-5W30-001',
  },
  {
    id: '6',
    name: 'Brake Fluid DOT 4',
    category: 'Maintenance',
    price: 12.50,
    stock: 320,
    sku: 'BRAKE-DOT4-001',
  },
  {
    id: '7',
    name: 'Car Wash Shampoo',
    category: 'Detailing',
    price: 6.99,
    stock: 150,
    sku: 'WASH-SHAMP-001',
  },
  {
    id: '8',
    name: 'Air Filter',
    category: 'Maintenance',
    price: 15.00,
    stock: 85,
    sku: 'FILTER-AIR-001',
  },
];

export const mockOrders: Order[] = [
  {
    id: '1',
    orderNumber: 'PW-2024-001',
    customerId: 'c1',
    customerName: 'John Smith',
    total: 125.50,
    status: 'delivered',
    date: '2024-04-20',
    items: 3,
  },
  {
    id: '2',
    orderNumber: 'PW-2024-002',
    customerId: 'c2',
    customerName: 'Sarah Johnson',
    total: 89.99,
    status: 'shipped',
    date: '2024-04-22',
    items: 2,
  },
  {
    id: '3',
    orderNumber: 'PW-2024-003',
    customerId: 'c3',
    customerName: 'Mike Wilson',
    total: 245.00,
    status: 'processing',
    date: '2024-04-24',
    items: 5,
  },
  {
    id: '4',
    orderNumber: 'PW-2024-004',
    customerId: 'c4',
    customerName: 'Emily Davis',
    total: 56.75,
    status: 'pending',
    date: '2024-04-25',
    items: 1,
  },
  {
    id: '5',
    orderNumber: 'PW-2024-005',
    customerId: 'c5',
    customerName: 'Robert Brown',
    total: 312.00,
    status: 'delivered',
    date: '2024-04-18',
    items: 8,
  },
];

export const mockCustomers: Customer[] = [
  {
    id: 'c1',
    name: 'John Smith',
    email: 'john@example.com',
    phone: '+1 (555) 123-4567',
    totalOrders: 5,
    totalSpent: 456.25,
    joinDate: '2023-01-15',
  },
  {
    id: 'c2',
    name: 'Sarah Johnson',
    email: 'sarah@example.com',
    phone: '+1 (555) 234-5678',
    totalOrders: 12,
    totalSpent: 1245.80,
    joinDate: '2022-06-20',
  },
  {
    id: 'c3',
    name: 'Mike Wilson',
    email: 'mike@example.com',
    phone: '+1 (555) 345-6789',
    totalOrders: 3,
    totalSpent: 285.50,
    joinDate: '2023-11-10',
  },
  {
    id: 'c4',
    name: 'Emily Davis',
    email: 'emily@example.com',
    phone: '+1 (555) 456-7890',
    totalOrders: 8,
    totalSpent: 654.30,
    joinDate: '2023-03-22',
  },
  {
    id: 'c5',
    name: 'Robert Brown',
    email: 'robert@example.com',
    phone: '+1 (555) 567-8901',
    totalOrders: 15,
    totalSpent: 2100.00,
    joinDate: '2022-01-05',
  },
];

export const mockCoupons: Coupon[] = [
  {
    id: '1',
    code: 'SAVE10',
    discount: 10,
    type: 'percentage',
    expiry: '2024-12-31',
    active: true,
  },
  {
    id: '2',
    code: 'FUEL5',
    discount: 5,
    type: 'fixed',
    expiry: '2024-06-30',
    active: true,
  },
  {
    id: '3',
    code: 'SUMMER20',
    discount: 20,
    type: 'percentage',
    expiry: '2024-08-31',
    active: false,
  },
];

// Analytics mock data
export const mockAnalytics = {
  totalRevenue: 45230.50,
  totalOrders: 324,
  averageOrderValue: 139.70,
  totalCustomers: 128,
  lowStockItems: 12,
  pendingOrders: 7,
};

export const mockChartData = [
  { name: 'Jan', revenue: 4000, orders: 24 },
  { name: 'Feb', revenue: 3000, orders: 18 },
  { name: 'Mar', revenue: 2000, orders: 28 },
  { name: 'Apr', revenue: 2780, orders: 39 },
  { name: 'May', revenue: 1890, orders: 48 },
  { name: 'Jun', revenue: 2390, orders: 52 },
];
