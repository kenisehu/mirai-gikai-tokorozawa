export type MeetingStage = {
  label: string;
  description: string;
};

const toTokyoDateKey = (date: Date) =>
  new Intl.DateTimeFormat("sv-SE", {
    timeZone: "Asia/Tokyo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);

/** 所沢市の公式日程に沿って、現在位置を市民向けに表す。 */
export function getCurrentMeetingStage(date: Date): MeetingStage {
  const dateKey = toTokyoDateKey(date);

  if (dateKey < "2026-09-01") {
    return { label: "開会前", description: "9月1日に開会予定です" };
  }
  if (dateKey <= "2026-09-03") {
    return {
      label: "議案説明",
      description: "市長から提出された議案の説明が行われる段階です",
    };
  }
  if (dateKey === "2026-09-04") {
    return {
      label: "議案質疑・委員会付託",
      description: "議案への質疑と、担当委員会への振り分けが行われます",
    };
  }
  if (dateKey <= "2026-09-13") {
    return {
      label: "委員会審査",
      description: "各委員会で議案の内容を詳しく審査しています",
    };
  }
  if (dateKey === "2026-09-14") {
    return {
      label: "採決日",
      description: "委員長報告・討論の後、議案の採決が行われます",
    };
  }
  if (dateKey <= "2026-09-24") {
    return {
      label: "一般質問",
      description: "議員が市政全般について質問する期間です",
    };
  }

  return {
    label: "会議終了",
    description: "公式の審議結果を確認して掲載内容を更新します",
  };
}
