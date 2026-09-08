"use client";

import { useEffect, useState } from "react";
import {
  getTextSizeLargeFromStorage,
  setTextSizeLargeToStorage,
} from "./storage";

export function useTextSizeToggle() {
  const [isLarge, setIsLarge] = useState(false);

  useEffect(() => {
    setIsLarge(getTextSizeLargeFromStorage());
  }, []);

  const handleToggle = (checked: boolean) => {
    setIsLarge(checked);
    setTextSizeLargeToStorage(checked);
    document.documentElement.classList.toggle("large-text", checked);
  };

  return { isLarge, handleToggle };
}
