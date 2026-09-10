import { redirect } from "next/navigation";

import { getCurrentAdmin } from "@/features/auth/server/lib/auth-server";
import { routes } from "@/lib/routes";

export default async function HomePage() {
  const admin = await getCurrentAdmin();

  // 運営者としてログイン済みの場合は訂正報告の確認画面へ
  if (admin) {
    redirect(routes.correctionReports());
  }

  // 未ログインまたは管理者でない場合はログイン画面へ
  redirect(routes.login());
}
