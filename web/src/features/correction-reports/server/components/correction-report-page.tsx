import { Container } from "@/components/layouts/container";
import { CorrectionReportForm } from "../../client/components/correction-report-form";

export function CorrectionReportPage({
  billId,
  billName,
}: {
  billId?: string;
  billName?: string;
}) {
  return (
    <Container>
      <main className="mx-auto max-w-2xl py-10 sm:py-16">
        <p className="text-sm font-bold text-primary">
          情報の正確さを一緒に守る
        </p>
        <h1 className="mt-2 text-3xl font-bold">訂正・改善を報告する</h1>
        <p className="mt-4 mb-8 leading-7 text-muted-foreground">
          誤っている事実や数字、分かりにくい説明、開けないリンクをお知らせください。個人情報の入力は不要です。
        </p>
        <CorrectionReportForm billId={billId} billName={billName} />
      </main>
    </Container>
  );
}
