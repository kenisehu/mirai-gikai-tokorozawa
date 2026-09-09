import { CorrectionReportsPage } from "@/features/correction-reports/server/components/correction-reports-page";

export default async function Page({
  searchParams,
}: {
  searchParams: Promise<{ status?: string }>;
}) {
  const { status } = await searchParams;
  return <CorrectionReportsPage status={status} />;
}
