"use client";

import type { ReactNode } from "react";

interface BillDetailClientProps {
  children: ReactNode;
}

/**
 * 議案詳細の表示ラッパー。
 * 所沢市版では常駐AIチャットを表示しない。
 */
export function BillDetailClient({ children }: BillDetailClientProps) {
  return <>{children}</>;
}
