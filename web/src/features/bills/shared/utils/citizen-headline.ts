const MAX_HEADLINE_LENGTH = 64;

/**
 * 公式名称とは別に、一覧で内容をつかみやすい一行見出しを作る。
 * 解説の先頭文だけを使い、一次資料にない情報は足さない。
 */
export function getCitizenHeadline(
  summary: string | null | undefined,
  officialTitle: string
): string {
  const normalized = summary
    ?.replace(/\s+/g, " ")
    .replace(
      /([\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}])\s+(?=[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}])/gu,
      "$1"
    )
    .trim();
  if (!normalized) {
    return officialTitle.replace(/（詳しい解説）$/, "");
  }

  const firstSentence = normalized.split("。")[0]?.trim() || normalized;
  if (firstSentence.length <= MAX_HEADLINE_LENGTH) {
    return firstSentence;
  }

  return `${firstSentence.slice(0, MAX_HEADLINE_LENGTH).trimEnd()}…`;
}
