const STORAGE_KEY = "text-size-large";

export function parseStoredTextSizeLarge(value: string | null): boolean {
  return value === "true";
}

export function getTextSizeLargeFromStorage(): boolean {
  if (typeof window === "undefined") return false;
  return parseStoredTextSizeLarge(localStorage.getItem(STORAGE_KEY));
}

export function setTextSizeLargeToStorage(enabled: boolean): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, enabled.toString());
}
