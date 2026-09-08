import { Container } from "@/components/layouts/container";
import { About } from "@/components/top/about";
import { ComingSoonSection } from "@/components/top/coming-soon-section";
import { CurrentMeetingSection } from "@/components/top/current-meeting-section";
import { Hero } from "@/components/top/hero";
import { TeamMirai } from "@/components/top/team-mirai";
import { BillDisclaimer } from "@/features/bills/client/components/bill-detail/bill-disclaimer";
import { BillSearchOverlay } from "@/features/bills/client/components/bill-search-overlay";
import { BillsByTagSection } from "@/features/bills/server/components/bills-by-tag-section";
import { CategoryTabs } from "@/features/bills/server/components/category-tabs";
import { FeaturedBillSection } from "@/features/bills/server/components/featured-bill-section";
import { PreviousSessionSection } from "@/features/bills/server/components/previous-session-section";
import { getFeaturedTags } from "@/features/bills/server/loaders/get-featured-tags";
import { getSuggestableBills } from "@/features/bills/server/loaders/get-suggestable-bills";
import { loadHomeData } from "@/features/bills/server/loaders/load-home-data";
import { countTagChipItems } from "@/features/bills/shared/utils/tag-chip-items";

/** カテゴリタブの「注目」から飛ばす先。 */
const FEATURED_ANCHOR = "featured";

// 会議の現在位置を日付に合わせて更新する。
export const revalidate = 3600;

export default async function Home() {
  // ゆくゆくタグ機能がマージされたらBFFに統合する
  const [
    { billsByTag, featuredBills, comingSoonBills, previousSessionData },
    suggestableBills,
    featuredTags,
  ] = await Promise.all([
    loadHomeData(),
    getSuggestableBills(),
    getFeaturedTags(),
  ]);

  const inSession = false;

  // 注目に出した法案はタグ別から外す。同じカードが2回並ぶのを避ける。
  const featuredIds = new Set(
    inSession ? featuredBills.map((bill) => bill.id) : []
  );
  const pickedBillsByTag = billsByTag
    .map((group) => ({
      ...group,
      bills: group.bills.filter((bill) => !featuredIds.has(bill.id)),
    }))
    // 注目に出た法案しか無かったタグは、見出しだけが残るので落とす。
    .filter((group) => group.bills.length > 0);

  // モーダルの件数は全会期の公開議案から数える。チップの飛び先が /bills で、
  // あちらも全会期を数えるため、押す前と後で数字が変わらない。
  // 候補用に取得済みの配列をそのまま使うので、集計のためのクエリは増えない。
  const searchTagChips = countTagChipItems(featuredTags, suggestableBills);

  return (
    <>
      <Hero billCount={suggestableBills.length} />
      <CurrentMeetingSection />
      <section id="bills" className="scroll-mt-24">
        <Container>
          <div className="pt-10 md:pt-8">
            <CategoryTabs
              billsByTag={billsByTag}
              featuredAnchor={inSession ? FEATURED_ANCHOR : undefined}
            />
          </div>
          {/* 検索の入口。キーワードとテーマの両方をモーダルに並べる */}
          <div className="flex justify-end pt-2">
            <BillSearchOverlay tags={searchTagChips} bills={suggestableBills} />
          </div>
        </Container>
      </section>

      {/* 議案一覧セクション */}
      <Container className="">
        <div className="py-10">
          <main className="flex flex-col gap-16">
            {/*
              注目の法案は会期中だけ出す。閉会中に「注目」を掲げても、審議が
              動いていない期間の情報を強調することになる。
              なお getFeaturedBills はアクティブ会期が無いと全件スコープに
              落ちるので、データ側だけでは空にならない。
            */}
            {inSession && (
              <section id={FEATURED_ANCHOR}>
                <FeaturedBillSection bills={featuredBills} />
              </section>
            )}

            {/* タグ別議案一覧セクション（タグに紐づく議案を全件出す） */}
            <BillsByTagSection billsByTag={pickedBillsByTag} />

            {/* Coming soonセクション */}
            <ComingSoonSection bills={comingSoonBills} />
          </main>
        </div>
      </Container>

      {/* 前回の市議会会議セクション（Archive） */}
      {previousSessionData && (
        <div className="bg-mirai-surface-muted py-10">
          <Container>
            <PreviousSessionSection
              session={previousSessionData.session}
              bills={previousSessionData.bills}
              totalBillCount={previousSessionData.totalBillCount}
            />
          </Container>
        </div>
      )}

      <Container>
        {/* みらい議会とは セクション */}
        <About />

        {/* チームみらいについて セクション */}
        <TeamMirai />

        {/* 免責事項 */}
        <BillDisclaimer isMunicipal />
      </Container>
    </>
  );
}
