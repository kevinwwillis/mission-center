/* performance_page/sidebar_order.rs
 *
 * Keeps the user's sidebar order when devices come and go.
 *
 * The saved order (setting `performance-sidebar-order`) is the source of
 * truth. Devices that are absent right now (a USB disk, a Docker veth, a disk
 * that dropped out briefly) keep their place in it, and a device that appears
 * later is put where the saved order says, not at its type's default spot.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/// Parses the stored `;`-separated order.
pub fn parse(raw: &str) -> Vec<&str> {
    raw.split(';').filter(|s| !s.is_empty()).collect()
}

/// The order to store after the user rearranged the sidebar.
///
/// `current` is the sidebar as it is now, top to bottom. Entries of `saved`
/// that are not in `current` are kept, each placed right after the entry that
/// preceded it in `saved`, so their positions survive until they come back.
pub fn merge(saved: &[&str], current: &[&str]) -> String {
    let mut result: Vec<&str> = current.to_vec();
    let mut anchor = 0usize;
    for name in saved {
        if let Some(pos) = result.iter().position(|r| r == name) {
            anchor = pos + 1;
        } else {
            result.insert(anchor, name);
            anchor += 1;
        }
    }
    result.join(";")
}

/// Where to insert `name` into a sidebar whose rows are `current`.
///
/// Returns `fallback` when the saved order does not mention `name`.
/// Otherwise the row goes right after the last current row that comes before
/// it in the saved order, or right before the first current row that comes
/// after it, or at `fallback` when no current row is in the saved order.
pub fn insert_index(saved: &[&str], current: &[&str], name: &str, fallback: i32) -> i32 {
    let rank = |n: &str| saved.iter().position(|s| *s == n);
    let my_rank = match rank(name) {
        Some(r) => r,
        None => return fallback,
    };

    let mut after_last_before: Option<usize> = None;
    let mut first_after: Option<usize> = None;
    for (i, row) in current.iter().enumerate() {
        match rank(row) {
            Some(r) if r < my_rank => after_last_before = Some(i + 1),
            Some(r) if r > my_rank && first_after.is_none() => first_after = Some(i),
            _ => {}
        }
    }

    after_last_before
        .or(first_after)
        .map(|i| i as i32)
        .unwrap_or(fallback)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn merge_keeps_absent_devices_in_place() {
        // veth1 is gone right now; the user swapped disk-a and disk-b.
        let saved = parse("cpu;memory;disk-a;veth1;disk-b");
        let current = ["cpu", "memory", "disk-b", "disk-a"];
        assert_eq!(merge(&saved, &current), "cpu;memory;disk-b;disk-a;veth1");
    }

    #[test]
    fn merge_with_nothing_absent_is_current_order() {
        let saved = parse("a;b;c");
        assert_eq!(merge(&saved, &["c", "a", "b"]), "c;a;b");
    }

    #[test]
    fn merge_from_empty_saved_order() {
        assert_eq!(merge(&parse(""), &["a", "b"]), "a;b");
    }

    #[test]
    fn absent_device_at_start_stays_at_start() {
        let saved = parse("usb;cpu;memory");
        assert_eq!(merge(&saved, &["cpu", "memory"]), "usb;cpu;memory");
    }

    #[test]
    fn returning_device_goes_to_saved_place() {
        let saved = parse("cpu;net-veth1;memory;disk-a");
        let current = ["cpu", "memory", "disk-a"];
        assert_eq!(insert_index(&saved, &current, "net-veth1", 3), 1);
    }

    #[test]
    fn returning_device_first_in_saved_order() {
        let saved = parse("disk-a;cpu;memory");
        assert_eq!(insert_index(&saved, &["cpu", "memory"], "disk-a", 2), 0);
    }

    #[test]
    fn unknown_device_uses_fallback() {
        let saved = parse("cpu;memory");
        assert_eq!(insert_index(&saved, &["cpu", "memory"], "disk-new", 2), 2);
    }

    #[test]
    fn rows_not_in_saved_order_are_skipped() {
        // disk-x is not in the saved order and sits between cpu and memory.
        let saved = parse("cpu;disk-a;memory");
        let current = ["cpu", "disk-x", "memory"];
        assert_eq!(insert_index(&saved, &current, "disk-a", 3), 1);
    }
}
