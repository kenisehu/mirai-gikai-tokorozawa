"use client";

import { Switch } from "@/components/ui/switch";
import { useTextSizeToggle } from "@/lib/text-size/use-text-size-toggle";

export function DesktopMenuTextSizeToggle() {
  const { isLarge, handleToggle } = useTextSizeToggle();

  return (
    <div className="fixed top-[172px] right-6 z-50">
      <div className="flex w-[332px] items-center gap-6 rounded-full bg-white px-6 py-5 pl-9 font-bold text-black">
        <span className="flex-1 text-xl">文字を大きくする</span>
        <Switch
          checked={isLarge}
          onCheckedChange={handleToggle}
          aria-label="文字サイズの切り替え"
        />
      </div>
    </div>
  );
}
