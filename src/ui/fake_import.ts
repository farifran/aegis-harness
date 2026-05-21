import { DatabaseClient } from "../infrastructure/database";

export function fakeImport(): void {
  console.log(DatabaseClient);
}