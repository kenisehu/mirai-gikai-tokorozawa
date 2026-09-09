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
  if (normalizeMeetingName(meetingName) !== CURRENT_MEETING) return [];

  const isFinancialStatement = billName.includes("決算");
  return [
    {
      date: "9月1日",
      title: "本会議に提出",
      description: "市長から提案理由と議案の説明が行われました。",
      status: "completed",
    },
    {
      date: "9月4日",
      title: "議案質疑・委員会付託",
      description: "本会議で質疑を行い、詳しい審査を委員会へ託しました。",
      status: "completed",
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
          description: "常任委員会・予算常任委員会などで審査されました。",
          status: "completed",
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
