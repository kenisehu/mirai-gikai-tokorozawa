import "server-only";
import { ArrowRight, BookOpen, Coins, MessageSquareText } from "lucide-react";
import Link from "next/link";
import { Container } from "@/components/layouts/container";
import { Button } from "@/components/ui/button";
import { routes } from "@/lib/routes";

export function SessionHighlights() {
  return (
    <section
      className="bg-mirai-surface-muted py-8"
      aria-labelledby="session-highlights"
    >
      <Container>
        <h2
          id="session-highlights"
          className="text-xl font-bold text-mirai-text"
        >
          今回の議会、ここから読む
        </h2>
        <p className="mt-2 text-sm text-mirai-text-secondary">
          暮らしに関係する予算、議員の質問、過去との違い。関心に合わせて入口を選べます。
        </p>
        <div className="mt-5 grid gap-4 md:grid-cols-3">
          <article className="rounded-xl border border-primary/20 bg-white p-5">
            <Coins className="mb-3 size-6 text-primary" aria-hidden="true" />
            <h3 className="font-bold text-mirai-text">
              「予算が増える」の中身は？
            </h3>
            <p className="mt-2 text-sm leading-relaxed text-mirai-text-secondary">
              子育て支援から保険会計の精算まで。新しい事業、基金への積立、複数年度の総額を分けて解説しています。
            </p>
            <Button asChild variant="outline" size="sm" className="mt-4">
              <Link href={routes.billsList()}>
                議案から予算を読む
                <ArrowRight className="size-4" />
              </Link>
            </Button>
          </article>
          <article className="rounded-xl border border-primary/20 bg-white p-5">
            <MessageSquareText
              className="mb-3 size-6 text-primary"
              aria-hidden="true"
            />
            <h3 className="font-bold text-mirai-text">議員は何を質問する？</h3>
            <p className="mt-2 text-sm leading-relaxed text-mirai-text-secondary">
              一般質問を議員・テーマから探せます。事前の質問通告と、実際に行われた答弁は区別して案内します。
            </p>
            <Button asChild variant="outline" size="sm" className="mt-4">
              <Link href={routes.generalQuestions()}>
                一般質問を探す
                <ArrowRight className="size-4" />
              </Link>
            </Button>
          </article>
          <article className="rounded-xl border border-primary/20 bg-white p-5">
            <BookOpen className="mb-3 size-6 text-primary" aria-hidden="true" />
            <h3 className="font-bold text-mirai-text">
              前の会議では何が決まった？
            </h3>
            <p className="mt-2 text-sm leading-relaxed text-mirai-text-secondary">
              2月・6月の議案と審議結果も掲載。以前の判断をたどり、今回の議案を読む参考にできます。
            </p>
            <Button asChild variant="outline" size="sm" className="mt-4">
              <Link href={routes.sessions()}>
                過去の会議を見る
                <ArrowRight className="size-4" />
              </Link>
            </Button>
          </article>
        </div>
      </Container>
    </section>
  );
}
