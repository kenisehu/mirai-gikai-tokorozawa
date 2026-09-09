import { MessageSquareWarning } from "lucide-react";
import type { Route } from "next";
import Link from "next/link";
import { Container } from "@/components/layouts/container";
import { Button } from "@/components/ui/button";
import { InterviewLandingSection } from "@/features/interview-config/client/components/interview-landing-section";
import { getInterviewConfig } from "@/features/interview-config/server/loaders/get-interview-config";
import { getPublicReportsByBillId } from "@/features/interview-report/server/loaders/get-public-reports-by-bill-id";
import { BillTopicsPreviewSection } from "@/features/user-topic-analysis/server/components/bill-topics-preview-section";
import { getPublicTopicAnalysis } from "@/features/user-topic-analysis/server/loaders/get-public-topic-analysis";
import { routes } from "@/lib/routes";
import { BillDetailClient } from "../../../client/components/bill-detail/bill-detail-client";
import { BillDisclaimer } from "../../../client/components/bill-detail/bill-disclaimer";
import { BillStatusProgress } from "../../../client/components/bill-detail/bill-status-progress";
import { MiraiStanceCard } from "../../../client/components/bill-detail/mirai-stance-card";
import type { BillWithContent } from "../../../shared/types";
import { getMunicipalResultStatus } from "../../../shared/utils/municipal-result-status";
import { findMunicipalDeliberationEvents } from "../../repositories/municipal-deliberation-repository";
import { BillShareButtons } from "../share/bill-share-buttons";
import { BillContent } from "./bill-content";
import { BillDetailHeader } from "./bill-detail-header";
import { MunicipalBillSource } from "./municipal-bill-source";
import { MunicipalBillStatus } from "./municipal-bill-status";
import { MunicipalBudgetSummaryCard } from "./municipal-budget-summary-card";
import { MunicipalDeliberationTimeline } from "./municipal-deliberation-timeline";

interface BillDetailLayoutProps {
  bill: BillWithContent;
}

export async function BillDetailLayout({ bill }: BillDetailLayoutProps) {
  const deliberation = bill.municipal_metadata
    ? await findMunicipalDeliberationEvents(bill.id)
    : null;
  const voteResult = deliberation?.events
    .filter((event) => event.event_type === "vote" && event.result)
    .at(-1)?.result;
  const municipalStatus = getMunicipalResultStatus(voteResult, bill.status);
  const showMiraiStance = bill.status === "preparing" || bill.mirai_stance;
  const [interviewConfig, publicReportsResult, topicAnalysis] =
    await Promise.all([
      getInterviewConfig(bill.id),
      getPublicReportsByBillId(bill.id),
      getPublicTopicAnalysis(bill.id),
    ]);

  return (
    <div className="container mx-auto pb-8 max-w-4xl">
      <BillDetailClient>
        <BillDetailHeader
          bill={bill}
          hasInterviewConfig={interviewConfig != null}
          opinionCount={topicAnalysis?.total_opinions ?? 0}
          topicCount={topicAnalysis?.topics.length ?? 0}
        />
        <Container>
          {/* 議案ステータス進捗 */}
          <div className="my-8">
            {bill.municipal_metadata ? (
              <MunicipalBillStatus
                status={municipalStatus}
                statusNote={voteResult ?? bill.status_note}
              />
            ) : (
              <BillStatusProgress
                status={bill.status}
                originatingHouse={bill.originating_house}
                statusNote={bill.status_note}
              />
            )}
          </div>

          <BillContent bill={bill} />
          {bill.municipal_metadata && (
            <>
              <MunicipalBudgetSummaryCard
                billName={bill.name}
                sourceUrl={
                  bill.municipal_metadata.bill_document_url ??
                  bill.municipal_metadata.official_page_url
                }
              />
              <MunicipalDeliberationTimeline
                billId={bill.id}
                billStatus={municipalStatus}
                meetingName={bill.municipal_metadata.meeting_name}
                billName={bill.name}
                scheduleUrl="https://www.city.tokorozawa.saitama.jp/shigikai/kaiki_nittei/nitteir8_9.html"
              />
              <MunicipalBillSource metadata={bill.municipal_metadata} />
            </>
          )}
        </Container>
      </BillDetailClient>

      <Container>
        {/* 法案のトピック一覧（AIインタビュー意見の整理） */}
        <div className="my-8">
          <BillTopicsPreviewSection
            billId={bill.id}
            topics={topicAnalysis?.topics ?? []}
            publicReportCount={publicReportsResult.totalCount}
          />
        </div>

        {interviewConfig != null && (
          <div className="my-8">
            <InterviewLandingSection billId={bill.id} />
          </div>
        )}
        {showMiraiStance && (
          <div className="my-8">
            <MiraiStanceCard
              stance={bill.mirai_stance}
              billStatus={bill.status}
            />
          </div>
        )}
        {/* シェアボタン */}
        <div className="my-8">
          <BillShareButtons bill={bill} />
        </div>

        {/* データの出典と免責事項 */}
        <div className="my-8">
          <BillDisclaimer isMunicipal={Boolean(bill.municipal_metadata)} />
        </div>

        <div className="my-8 rounded-2xl border bg-muted/30 p-5 text-center">
          <p className="font-bold">誤りや分かりにくい点がありましたか？</p>
          <p className="mt-1 mb-4 text-sm text-muted-foreground">
            個人情報なしで、確認担当者へ知らせることができます。
          </p>
          <Button asChild variant="outline" size="sm">
            <Link href={routes.corrections(bill.id, bill.name) as Route}>
              <MessageSquareWarning />
              訂正・改善を報告する
            </Link>
          </Button>
        </div>
      </Container>
    </div>
  );
}
