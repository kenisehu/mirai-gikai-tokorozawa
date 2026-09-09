import type { Metadata } from "next";
import { ArchiveBillPage } from "@/features/session-archive/server/components/archive-bill-page";
import { getArchiveBills } from "@/features/session-archive/shared/utils/archive-bills";

type Props = { params: Promise<{ slug: string; billId: string }> };

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug, billId } = await params;
  const bill = getArchiveBills(slug).find((item) => item.id === billId);
  return {
    title: bill ? `${bill.number} ${bill.headline}` : "議案が見つかりません",
  };
}

export default async function Page({ params }: Props) {
  return <ArchiveBillPage {...(await params)} />;
}
