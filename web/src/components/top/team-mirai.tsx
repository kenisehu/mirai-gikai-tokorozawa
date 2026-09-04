import { LinkButton } from "./link-button";

export function TeamMirai() {
  return (
    <div className="py-10">
      <div className="flex flex-col gap-6">
        {/* ヘッダー */}
        <div className="flex flex-col gap-4">
          <h2 className="font-lexend text-2xl font-bold tracking-wide text-mirai-text">
            CITIZEN PROJECT
          </h2>
          <p className="text-sm font-bold text-primary-accent">
            市民による独立プロジェクト
          </p>
        </div>

        {/* コンテンツ */}
        <div className="flex flex-col gap-6">
          <div className="flex flex-col gap-3">
            <p className="text-[15px] leading-[28px] text-black">
              このサービスは、所沢市や所沢市議会、政党チームみらいが運営する公式サービスではありません。市民が市議会の情報へアクセスしやすくすることを目指す、独立した非公式プロジェクトです。
            </p>
          </div>

          {/* ボタングループ */}
          <div className="flex flex-col gap-4">
            <LinkButton
              href="https://gikai.team-mir.ai/"
              icon={{
                src: "/icons/info-icon.svg",
                alt: "",
                width: 23,
                height: 22,
              }}
            >
              本家「みらい議会」を見る
            </LinkButton>
          </div>
        </div>
      </div>
    </div>
  );
}
