import Image from "next/image";
import { EXTERNAL_LINKS } from "@/config/external-links";
import { LinkButton } from "./link-button";

export function About() {
  return (
    <div className="py-10">
      <div className="flex flex-col gap-4">
        {/* ヘッダー */}
        <div className="flex flex-col gap-4">
          <h2>
            <Image
              src="/icons/about-typography.svg"
              alt="About"
              width={143}
              height={36}
              priority
            />
          </h2>
          <p className="text-sm font-bold text-primary-accent">
            みらい議会＠所沢市とは
          </p>
        </div>

        {/* コンテンツ */}
        <div className="flex flex-col gap-6">
          <div className="flex flex-col gap-3">
            <h3 className="text-2xl font-bold leading-[43.2px]">
              所沢市議会の議論を
              <br />
              できる限りわかりやすく
            </h3>
            <p className="text-[15px] leading-[28px] text-black">
              みらい議会＠所沢市は、市議会で今どんな議案が検討されているかを、市民にわかりやすく伝えるための非公式プラットフォームです。特定の政党や会派に偏らず、市民が市政を知り、考えるきっかけをつくります。
            </p>
          </div>

          {/* もっと詳しく知るボタン */}
          <LinkButton
            href={EXTERNAL_LINKS.ORIGINAL_MIRAI_GIKAI}
            icon={{
              src: "/icons/note-icon.png",
              alt: "note",
              width: 25,
              height: 25,
            }}
          >
            本家みらい議会について
          </LinkButton>
        </div>
      </div>
    </div>
  );
}
