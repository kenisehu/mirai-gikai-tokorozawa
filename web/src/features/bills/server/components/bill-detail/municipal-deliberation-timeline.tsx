import { CalendarClock, Check, ExternalLink } from "lucide-react";
import type { Route } from "next";
import Link from "next/link";
import { getTokorozawaDeliberationSchedule } from "../../../shared/utils/tokorozawa-deliberation-schedule";

export function MunicipalDeliberationTimeline({
  meetingName,
  billName,
  scheduleUrl,
}: {
  meetingName: string;
  billName: string;
  scheduleUrl: string;
}) {
  const steps = getTokorozawaDeliberationSchedule(meetingName, billName);
  if (steps.length === 0) return null;

  return (
    <section className="my-8 rounded-2xl border bg-white p-5 shadow-sm sm:p-6">
      <div className="flex items-center gap-2">
        <CalendarClock className="size-5 text-primary" />
        <h2 className="text-xl font-bold">この議案の審議の流れ</h2>
      </div>
      <ol className="mt-6 space-y-5">
        {steps.map((step) => (
          <li key={`${step.date}-${step.title}`} className="flex gap-3">
            <span
              className={`mt-0.5 flex size-7 shrink-0 items-center justify-center rounded-full ${step.status === "completed" ? "bg-primary text-primary-foreground" : "border-2 border-primary bg-white text-primary"}`}
            >
              {step.status === "completed" ? (
                <Check className="size-4" />
              ) : (
                <span className="size-2 rounded-full bg-primary" />
              )}
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
        委員会での詳しい質疑・答弁は、公式記録の公開後に追記します。
      </div>
      <Link
        href={scheduleUrl as Route}
        target="_blank"
        rel="noreferrer"
        className="mt-4 inline-flex items-center gap-1 text-sm font-bold text-primary underline underline-offset-4"
      >
        所沢市議会の公式日程
        <ExternalLink className="size-4" />
      </Link>
    </section>
  );
}
