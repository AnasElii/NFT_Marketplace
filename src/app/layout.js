import { Inter } from "next/font/google";
import "./globals.css";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { WalletProvider } from "@/context/WalletContext";
import { ToastContainer } from "react-toastify";

const inter = Inter({ subsets: ["latin"] });

export const metadata = {
  title: "Create Next App",
  description: "Generated by create next app",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <WalletProvider >
          <div className="flex flex-col min-h-screen">
            <Header />
            <main style={{ flex: '1 0 auto', width: '100%', backgroundColor: '#6B7280', paddingTop: 10 }}>
              {children}
              <ToastContainer
                position="top-right"
                autoClose={5000}
                hideProgressBar={false}
                newestOnTop
                closeOnClick
                rtl={false}
                pauseOnFocusLoss
                draggable
                pauseOnHover
                theme="light"
              />
            </main>
            <Footer style={{ flexShrink: '0' }} />
          </div>
        </WalletProvider>
      </body>
    </html>
  );
}