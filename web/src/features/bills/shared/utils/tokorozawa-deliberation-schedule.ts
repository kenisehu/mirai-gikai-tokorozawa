export type DeliberationStep = {
  date: string;
  title: string;
  description: string;
  status: "completed" | "scheduled";
};

const CURRENT_MEETING = "令和8年第5回(9月)定例会議";

function normalizeMeetingName(value: string): string {
  return value.replaceAll("（", "(").replaceAll("）", ")");
}

export function getTokorozawaDeliberationSchedule(
  meetingName: string,
  billName: string
): DeliberationStep[] {
  if (!normalizeMeetingName(meetingName).includes(CURRENT_MEETING)) return [];

  const isFinancialStatement = billName.includes("決算");
  return [
    {
      date: "9月1日",
      title: "本会議に提出",
      description:
        "議会全体の日程に記載された提案説明日です。個別議案の実施確認とは区別しています。",
      status: "scheduled",
    },
    {
      date: "9月4日",
      title: "議案質疑・委員会付託",
      description:
        "議会全体の議案質疑・委員会付託の日程です。議案ごとの付託先は公式記録で確認します。",
      status: "scheduled",
    },
    isFinancialStatement
      ? {
          date: "9月28〜30日",
          title: "決算特別委員会",
          description: "決算の内容を特別委員会で審査する予定です。",
          status: "scheduled",
        }
      : {
          date: "9月7〜8日",
          title: "委員会審査",
          description:
            "議会全体の委員会審査の日程です。この議案の審査完了を示すものではありません。",
          status: "scheduled",
        },
    ...(!isFinancialStatement
      ? [
          {
            date: "9月14日",
            title: "委員長報告・討論・採決",
            description: "委員会の審査報告を受け、本会議で採決する予定です。",
            status: "scheduled" as const,
          },
        ]
      : []),
  ];
}
