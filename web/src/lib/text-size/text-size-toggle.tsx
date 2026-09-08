"use client";

import { Switch } from "@/components/ui/switch";
import { useTextSizeToggle } from "./use-text-size-toggle";

export function TextSizeToggle() {
  const { isLarge, handleToggle } = useTextSizeToggle();

  return (
    <div className="flex items-center justify-between gap-4">
      <span className="text-sm font-medium">文字を大きくする</span>
      <Switch
        checked={isLarge}
        onCheckedChange={handleToggle}
        aria-label="文字サイズの切り替え"
      />
    </div>
  );
}
