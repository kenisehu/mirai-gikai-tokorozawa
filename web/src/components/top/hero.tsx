import { ArrowDown, ExternalLink, Search } from "lucide-react";
import Link from "next/link";
import { Container } from "@/components/layouts/container";
import { Button } from "@/components/ui/button";
import { siteConfig } from "@/config/site.config";
import { routes } from "@/lib/routes";

interface HeroProps {
  billCount: number;
}

export function Hero({ billCount }: HeroProps) {
  return (
    <section className="relative overflow-hidden bg-mirai-hero-gradient pt-28 pb-12 md:pt-20 md:pb-16">
      <Container>
        <div className="max-w-3xl">
          <p className="mb-4 inline-flex rounded-full bg-white/80 px-4 py-2 text-sm font-bold text-primary-accent shadow-sm">
            市民がつくる、非公式の議会情報サイト
          </p>
          <h1 className="text-3xl font-bold leading-[1.5] tracking-wide text-mirai-text md:text-5xl md:leading-[1.35]">
            いま所沢市議会で
            <br />
            話し合われていることを、
            <br className="hidden sm:block" />
            やさしい言葉で。
          </h1>
          <p className="mt-5 max-w-2xl text-base leading-8 text-mirai-text-secondary md:text-lg">
            難しい議案を短い要約と詳しい解説で読み解けます。掲載情報は必ず所沢市の公式資料にもつながっています。
          </p>

          <div className="mt-7 flex flex-wrap gap-3">
            <Button asChild size="lg" className="rounded-full px-6">
              <Link href={routes.billsList()}>
                <Search className="size-4" />
                {billCount}件の議案を見る
              </Link>
            </Button>
            <Button
              asChild
              size="lg"
              variant="outline"
              className="rounded-full border-primary bg-white/80 px-6 text-primary-accent"
            >
              <Link
                href={siteConfig.councilBillsDetailUrl}
                target="_blank"
                rel="noreferrer"
              >
                所沢市の公式情報
                <ExternalLink className="size-4" />
              </Link>
            </Button>
          </div>

          <a
            href="#bills"
            className="mt-9 inline-flex items-center gap-2 text-sm font-bold text-primary-accent"
          >
            このページで議案を探す
            <ArrowDown className="size-4" />
          </a>
        </div>
      </Container>
    </section>
  );
}
