import { Sidebar } from '@/components/sidebar'
import { DashboardWrapper } from '@/components/dashboard-wrapper'
import { Toaster } from '@/components/ui/sonner'

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <DashboardWrapper>
      <div className="flex h-screen bg-background">
        <Sidebar />
        <main className="flex-1 overflow-auto">
          {children}
        </main>
        <Toaster />
      </div>
    </DashboardWrapper>
  )
}
