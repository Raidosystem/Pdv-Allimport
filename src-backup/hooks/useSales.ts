import { useState, useCallback, useEffect } from 'react'
import type { CartItem, Product, PaymentDetails } from '../types/sales'

export function useCart() {
  const [items, setItems] = useState<CartItem[]>([])

  const addItem = useCallback((product: Product, quantity: number = 1) => {
    setItems(prevItems => {
      const existingItem = prevItems.find(item => item.product.id === product.id)
      
      if (existingItem) {
        return prevItems.map(item =>
          item.product.id === product.id
            ? {
                ...item,
                quantity: item.quantity + quantity,
                total_price: (item.quantity + quantity) * item.unit_price
              }
            : item
        )
      }
      
      return [
        ...prevItems,
        {
          product,
          quantity,
          unit_price: product.price,
          total_price: product.price * quantity
        }
      ]
    })
  }, [])

  const updateQuantity = useCallback((productId: string, quantity: number) => {
    if (quantity <= 0) {
      removeItem(productId)
      return
    }

    setItems(prevItems =>
      prevItems.map(item =>
        item.product.id === productId
          ? {
              ...item,
              quantity,
              total_price: quantity * item.unit_price
            }
          : item
      )
    )
  }, [])

  const updatePrice = useCallback((productId: string, price: number) => {
    setItems(prevItems =>
      prevItems.map(item =>
        item.product.id === productId
          ? {
              ...item,
              unit_price: price,
              total_price: item.quantity * price
            }
          : item
      )
    )
  }, [])

  const removeItem = useCallback((productId: string) => {
    setItems(prevItems => prevItems.filter(item => item.product.id !== productId))
  }, [])

  const clearCart = useCallback(() => {
    setItems([])
  }, [])

  const getSubtotal = useCallback(() => {
    return items.reduce((total, item) => total + item.total_price, 0)
  }, [items])

  const getItemsCount = useCallback(() => {
    return items.reduce((count, item) => count + item.quantity, 0)
  }, [items])

  return {
    items,
    addItem,
    updateQuantity,
    updatePrice,
    removeItem,
    clearCart,
    getSubtotal,
    getItemsCount
  }
}

export function useSaleCalculation() {
  const [discountType, setDiscountType] = useState<'percentage' | 'fixed'>('percentage')
  const [discountValue, setDiscountValue] = useState<number>(0)
  const [payments, setPayments] = useState<PaymentDetails[]>([])

  const calculateDiscount = useCallback((subtotal: number) => {
    if (discountType === 'percentage') {
      return (subtotal * discountValue) / 100
    }
    return Math.min(discountValue, subtotal)
  }, [discountType, discountValue])

  const getTotalPayments = useCallback(() => {
    return payments.reduce((total, payment) => total + payment.amount, 0)
  }, [payments])

  const addPayment = useCallback((payment: PaymentDetails) => {
    setPayments(prev => [...prev, payment])
  }, [])

  const removePayment = useCallback((index: number) => {
    setPayments(prev => prev.filter((_, i) => i !== index))
  }, [])

  const updatePayment = useCallback((index: number, payment: PaymentDetails) => {
    setPayments(prev => prev.map((p, i) => i === index ? payment : p))
  }, [])

  const clearPayments = useCallback(() => {
    setPayments([])
  }, [])

  const getChangeAmount = useCallback((totalAmount: number, cashReceived?: number) => {
    if (!cashReceived) return 0
    const totalPaid = getTotalPayments() + cashReceived
    return Math.max(0, totalPaid - totalAmount)
  }, [getTotalPayments])

  const resetCalculation = useCallback(() => {
    setDiscountType('percentage')
    setDiscountValue(0)
    setPayments([])
  }, [])

  return {
    discountType,
    setDiscountType,
    discountValue,
    setDiscountValue,
    payments,
    addPayment,
    removePayment,
    updatePayment,
    clearPayments,
    calculateDiscount,
    getTotalPayments,
    getChangeAmount,
    resetCalculation
  }
}

export function useKeyboardShortcuts(onNewSale: () => void, onAddProduct: () => void) {
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      // CTRL + N = Nova venda
      if (event.ctrlKey && event.key === 'n') {
        event.preventDefault()
        onNewSale()
      }
      
      // Enter = Adicionar produto (quando campo de busca está focado)
      if (event.key === 'Enter' && event.target instanceof HTMLInputElement) {
        if (event.target.getAttribute('data-search') === 'product') {
          event.preventDefault()
          onAddProduct()
        }
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [onNewSale, onAddProduct])
}

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => {
      clearTimeout(handler)
    }
  }, [value, delay])

  return debouncedValue
}
