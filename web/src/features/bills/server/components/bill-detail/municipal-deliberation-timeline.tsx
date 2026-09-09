import { CalendarClock, ExternalLink } from "lucide-react";
import type { Route } from "next";
import Link from "next/link";
import { getTokorozawaDeliberationSchedule } from "../../../shared/utils/tokorozawa-deliberation-schedule";
import { findMunicipalDeliberationEvents } from "../../repositories/municipal-deliberation-repository";

export async function MunicipalDeliberationTimeline({
  billId,
  billStatus,
  meetingName,
  billName,
  scheduleUrl,
}: {
  billId: string;
  billStatus: string;
  meetingName: string;
  billName: string;
  scheduleUrl: string;
}) {
  const { events, unavailable } = await findMunicipalDeliberationEvents(billId);
  const hasResult = events.some(
    (event) => event.event_type === "vote" && event.result
  );
  const finished =
    hasResult || billStatus === "enacted" || billStatus === "rejected";
  const steps = finished
    ? []
    : getTokorozawaDeliberationSchedule(meetingName, billName);

  return (
    <section className="my-8 rounded-2xl border bg-white p-5 shadow-sm sm:p-6">
      <div className="flex items-center gap-2">
        <CalendarClock className="size-5 text-primary" />
        <h2 className="text-xl font-bold">この議案の審議の流れ</h2>
      </div>
      <h3 className="mt-5 font-bold">公式記録で確認できた審議</h3>
      {events.length === 0 ? (
        <p className="mt-2 text-sm text-muted-foreground">
          {unavailable
            ? "審議記録を取得できませんでした。公式資料をご確認ください。"
            : "この議案の個別の審議記録は、当サイトではまだ登録していません。未実施という意味ではありません。"}
        </p>
      ) : (
        <ol className="mt-3 space-y-4">
          {events.map((event) => (
            <li key={event.id} className="rounded-xl border p-4">
              <p className="text-sm text-muted-foreground">
                {event.event_date} {event.body_name}
              </p>
              <p className="font-bold">{event.summary}</p>
              {event.question && (
                <p className="mt-2 text-sm">質問：{event.question}</p>
              )}
              {event.answer && (
                <p className="mt-2 text-sm">答弁：{event.answer}</p>
              )}
              {event.result && (
                <p className="mt-2 font-bold">結果：{event.result}</p>
              )}
              <Link
                href={event.source_url as Route}
                target="_blank"
                rel="noreferrer"
                className="mt-2 inline-block text-sm text-primary underline"
              >
                この記録の公式資料
              </Link>
            </li>
          ))}
        </ol>
      )}
      {steps.length > 0 && (
        <p className="mt-6 text-sm font-bold">
          参考：会期全体の公式日程（2026年9月・個別議案の実績ではありません）
        </p>
      )}
      <ol className="mt-6 space-y-5">
        {steps.map((step) => (
          <li key={`${step.date}-${step.title}`} className="flex gap-3">
            <span className="mt-0.5 flex size-7 shrink-0 items-center justify-center rounded-full border-2 border-primary bg-white text-primary">
              <span className="size-2 rounded-full bg-primary" />
            </span>
            <div>
              <p className="text-xs font-bold text-primary">{step.date}</p>
              <p className="font-bold">{step.title}</p>
              <p className="mt-1 text-sm leading-6 text-muted-foreground">
                {step.description}
              </p>
            </div>
          </li>
        ))}
      </ol>
      <div className="mt-6 rounded-xl bg-muted/40 p-4 text-sm leading-6">
        日付が過ぎただけでは審査済み・可決とは判定しません。質疑・答弁・採決結果は、議案ごとの公式記録を確認して掲載します。
      </div>
      {steps.length > 0 && (
        <Link
          href={scheduleUrl as Route}
          target="_blank"
          rel="noreferrer"
          className="mt-4 inline-flex items-center gap-1 text-sm font-bold text-primary underline underline-offset-4"
        >
          所沢市議会の公式日程
          <ExternalLink className="size-4" />
        </Link>
      )}
    </section>
  );
}
