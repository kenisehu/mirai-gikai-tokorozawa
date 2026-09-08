"use client";

import { Menu } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { routes } from "@/lib/routes";
import { RubyToggle } from "@/lib/rubyful";
import { TextSizeToggle } from "@/lib/text-size/text-size-toggle";

export function HamburgerMenu() {
  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button
          variant="ghost"
          size="icon"
          className="h-10 w-10"
          aria-label="メニューを開く"
        >
          <Menu className="h-5 w-5" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-64" align="end">
        <div className="flex flex-col gap-4">
          <RubyToggle />
          <TextSizeToggle />
          <div className="border-t pt-3 text-sm">
            <Link href={routes.faq()} className="font-medium hover:underline">
              よくある質問
            </Link>
          </div>
        </div>
      </PopoverContent>
    </Popover>
  );
}
