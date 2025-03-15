import { Pipe, PipeTransform } from '@angular/core';

/**
 * A pipe to extract unique tajweed rules from highlights array
 */
@Pipe({
  name: 'uniqueRules',
  standalone: false
})
export class UniqueRulesPipe implements PipeTransform {
  transform(highlights: { rule: string; color: string; start: number; end: number; }[] | undefined): { rule: string; color: string; }[] {
    if (!highlights || !highlights.length) {
      return [];
    }

    // Create a map to deduplicate rules
    const rulesMap = new Map<string, { rule: string; color: string; }>();

    // Add each rule to the map
    highlights.forEach(h => {
      if (!rulesMap.has(h.rule)) {
        rulesMap.set(h.rule, { rule: h.rule, color: h.color });
      }
    });

    // Convert map to array
    return Array.from(rulesMap.values());
  }
}