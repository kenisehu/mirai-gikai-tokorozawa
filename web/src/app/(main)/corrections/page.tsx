import { CorrectionReportPage } from "@/features/correction-reports/server/components/correction-report-page";

export default async function Page({
  searchParams,
}: {
  searchParams: Promise<{ billId?: string; billName?: string }>;
}) {
  const { billId, billName } = await searchParams;
  return <CorrectionReportPage billId={billId} billName={billName} />;
}
