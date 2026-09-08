import { CalendarDays, ExternalLink, Vote } from "lucide-react";
import type { Route } from "next";
import Link from "next/link";
import { Container } from "@/components/layouts/container";
import { Button } from "@/components/ui/button";
import { siteConfig } from "@/config/site.config";
import { getCurrentMeetingStage } from "@/features/council/shared/utils/current-meeting-stage";
import { routes } from "@/lib/routes";

export function CurrentMeetingSection() {
  const stage = getCurrentMeetingStage(new Date());

  return (
    <section className="border-y border-primary/20 bg-white py-7">
      <Container>
        <div className="grid gap-5 md:grid-cols-[1fr_auto] md:items-center">
          <div>
            <div className="mb-2 flex flex-wrap items-center gap-2">
              <span className="rounded-full bg-primary px-3 py-1 text-xs font-bold text-white">
                現在の議会
              </span>
              <span className="rounded-full bg-mirai-surface-muted px-3 py-1 text-xs font-bold text-primary-accent">
                {stage.label}
              </span>
            </div>
            <h2 className="text-xl font-bold text-mirai-text md:text-2xl">
              {siteConfig.currentMeeting.name}
            </h2>
            <p className="mt-1 text-sm font-bold text-mirai-text-secondary">
              9月1日〜24日・このサイトの掲載対象：
              {siteConfig.currentMeeting.scope}
            </p>
            <p className="mt-2 text-sm text-mirai-text-secondary">
              {stage.description}。市長提出議案の採決は9月14日の予定です。
            </p>
          </div>
          <div className="flex flex-wrap gap-2">
            <Button asChild variant="outline" size="sm">
              <Link
                href={siteConfig.currentMeeting.scheduleUrl}
                target="_blank"
                rel="noreferrer"
              >
                <CalendarDays className="size-4" />
                公式日程
                <ExternalLink className="size-3" />
              </Link>
            </Button>
            <Button asChild variant="outline" size="sm">
              <Link href={routes.sessions() as Route}>
                <Vote className="size-4" />
                過去の会議
              </Link>
            </Button>
          </div>
        </div>
        <p className="mt-4 text-xs text-mirai-text-note">
          公式日程の確認日：2026年9月4日（予定は変更される場合があります）
        </p>
      </Container>
    </section>
  );
}
