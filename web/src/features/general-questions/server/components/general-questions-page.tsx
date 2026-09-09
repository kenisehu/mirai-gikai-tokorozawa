import { CalendarDays, ExternalLink, Radio } from "lucide-react";
import type { Route } from "next";
import Link from "next/link";
import { Container } from "@/components/layouts/container";
import { Button } from "@/components/ui/button";
import { TOKOROZAWA_GENERAL_QUESTION_DAYS } from "../../shared/tokorozawa-general-questions";

const OFFICIAL_PAGE =
  "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai5/202609ippan.html";
const STREAM_URL =
  "https://smart.discussvision.net/smart/tenant/tokorozawa/WebView/rd/council_1.html";

export function GeneralQuestionsPage() {
  return (
    <Container>
      <main className="mx-auto max-w-4xl py-10 sm:py-16">
        <p className="text-sm font-bold text-primary">
          令和8年第5回（9月）定例会議
        </p>
        <h1 className="mt-2 text-3xl font-bold">一般質問</h1>
        <p className="mt-4 leading-7 text-muted-foreground">
          市議会議員27人が、市政の課題を市長や担当部局へ質問します。議案の審議とは別のものです。
        </p>
        <div className="mt-6 flex flex-wrap gap-3">
          <Button asChild variant="outline" size="sm">
            <Link href={OFFICIAL_PAGE} target="_blank" rel="noreferrer">
              <ExternalLink />
              所沢市の公式ページ
            </Link>
          </Button>
          <Button asChild variant="outline" size="sm">
            <Link href={STREAM_URL} target="_blank" rel="noreferrer">
              <Radio />
              議会中継を見る
            </Link>
          </Button>
        </div>
        <div className="mt-10 space-y-10">
          {TOKOROZAWA_GENERAL_QUESTION_DAYS.map((day) => (
            <section key={day.date}>
              <div className="mb-4 flex flex-wrap items-center justify-between gap-3 border-b pb-3">
                <h2 className="flex items-center gap-2 text-xl font-bold">
                  <CalendarDays className="size-5 text-primary" />
                  {day.date}
                </h2>
                <Link
                  href={day.pdfUrl as Route}
                  target="_blank"
                  rel="noreferrer"
                  className="text-sm font-bold text-primary underline underline-offset-4"
                >
                  この日の通告書PDF
                </Link>
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                {day.questioners.map((person) => (
                  <article
                    key={person.order}
                    className="rounded-2xl border bg-white p-5 shadow-sm"
                  >
                    <div className="flex items-baseline gap-2">
                      <span className="text-xs font-bold text-primary">
                        {person.order}番
                      </span>
                      <h3 className="text-lg font-bold">{person.name}</h3>
                    </div>
                    <p className="mt-1 text-xs text-muted-foreground">
                      {person.group}
                    </p>
                    <div className="mt-4 flex flex-wrap gap-2">
                      {person.themes.map((theme) => (
                        <span
                          key={theme}
                          className="rounded-full bg-muted px-2.5 py-1 text-xs font-medium"
                        >
                          {theme}
                        </span>
                      ))}
                    </div>
                  </article>
                ))}
              </div>
            </section>
          ))}
        </div>
      </main>
    </Container>
  );
}
