import { Color, Icon } from "@raycast/api";
import type { DomainSnapshot, TransferProgress } from "./models";

const decimalUnits = ["B", "KB", "MB", "GB", "TB", "PB"];

export function formatBytes(bytes: number): string {
  if (!Number.isFinite(bytes)) {
    return "unknown";
  }

  let value = Math.max(0, bytes);
  let unitIndex = 0;

  while (value >= 1000 && unitIndex < decimalUnits.length - 1) {
    value /= 1000;
    unitIndex += 1;
  }

  const digits = value >= 10 || unitIndex === 0 ? 0 : 1;
  return `${value.toFixed(digits)} ${decimalUnits[unitIndex]}`;
}

export function formatPercent(fraction: number): string {
  if (!Number.isFinite(fraction)) {
    return "unknown";
  }

  return `${(fraction * 100).toFixed(1)}%`;
}

export function formatTransfer(progress: TransferProgress | null | undefined): string {
  if (!progress) {
    return "No active byte total";
  }

  return `${formatBytes(progress.completedBytes)} / ${formatBytes(progress.totalBytes)} (${formatPercent(progress.fraction)})`;
}

export function formatRemaining(progress: TransferProgress | null | undefined): string | undefined {
  if (!progress) {
    return undefined;
  }

  return `${formatBytes(progress.remainingBytes)} remaining`;
}

export function formatObservedAt(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return date.toLocaleTimeString();
}

export function domainStatusIcon(snapshot: DomainSnapshot) {
  if (snapshot.probeError) {
    return { source: Icon.Warning, tintColor: Color.Red };
  }

  if (snapshot.health.needsAuth) {
    return { source: Icon.Lock, tintColor: Color.Orange };
  }

  if (snapshot.upload || snapshot.download) {
    return { source: Icon.Cloud, tintColor: Color.Blue };
  }

  if (snapshot.health.isActive) {
    return { source: Icon.Circle, tintColor: Color.Green };
  }

  return { source: Icon.CheckCircle, tintColor: Color.Green };
}

export function statusAccessory(snapshot: DomainSnapshot): string {
  if (snapshot.probeError) {
    return "Error";
  }

  const activeTransfers = [snapshot.upload, snapshot.download].filter(Boolean).length;
  if (activeTransfers > 0) {
    return activeTransfers === 1 ? "1 transfer" : `${activeTransfers} transfers`;
  }

  if (snapshot.health.needsAuth) {
    return "Needs sign-in";
  }

  if (snapshot.health.isActive) {
    return "Active";
  }

  return "Idle";
}
