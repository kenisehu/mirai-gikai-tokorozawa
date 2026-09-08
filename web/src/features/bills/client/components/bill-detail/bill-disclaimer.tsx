import { LinkButton } from "@/components/top/link-button";
import { EXTERNAL_LINKS } from "@/config/external-links";
import { ManualRuby } from "@/lib/rubyful/manual-ruby";

export function BillDisclaimer({
  isMunicipal = false,
}: {
  isMunicipal?: boolean;
}) {
  return (
    <div className="space-y-6 pt-4 pb-10">
      {/* データの出典について */}
      <div className="space-y-3">
        <h3 className="text-sm font-bold text-black">掲載コンテンツについて</h3>
        <p className="text-xs leading-relaxed text-mirai-text-note">
          {isMunicipal ? (
            <>
              掲載されている議案情報は、所沢市が公開している一次資料を基に、本サイトが独自に整理したものです。本サイトは所沢市および所沢市議会の公式サイトではありません。
            </>
          ) : (
            <>
              掲載されている法案情報は、国会に提出された議案などの公開情報を基に、チームみらいがAIを活用しながら背景情報を整理したものです。掲載法案は主に、内閣提出法案（
              <ManualRuby ruby="かくほう">閣法</ManualRuby>
              ）を対象としております。
            </>
          )}
        </p>
      </div>

      {/* 掲載コンテンツについての免責事項 */}
      <div className="space-y-3">
        <h3 className="text-sm font-bold text-black">免責事項</h3>
        <p className="text-xs leading-relaxed text-mirai-text-note">
          本サイトで公開する情報は、可能な限り正確かつ最新の情報を反映するよう努めていますが、その正確性・完全性・即時性について保証するものではありません。正確な情報は、公式文書や一次資料をご確認ください。
        </p>
      </div>

      <LinkButton
        href={EXTERNAL_LINKS.FAQ}
        icon={{
          src: "/icons/question-bubble.svg",
          alt: "note",
          width: 22,
          height: 22,
        }}
      >
        よくある質問
      </LinkButton>
    </div>
  );
}
