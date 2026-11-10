/* Check complete menu transport against the image's own libgem and gemd.
 * MIT License; Copyright (C) 2026 Tomaz Stih. */
#include <gem.h>
#include <assert.h>
#include <stdint.h>
#include <stdio.h>

static void menu_tree(OBJECT *tree, WORD count) {
    for (WORD i = 0; i < count; ++i)
        tree[i] = (OBJECT){NIL, NIL, NIL, G_IBOX, 0, 0, 0, 0, 0, 80, 16};
    tree[0].ob_head = 1; tree[0].ob_tail = 4;
    tree[1].ob_next = 4; tree[1].ob_head = tree[1].ob_tail = 2;
    tree[1].ob_type = G_BOX;
    tree[2].ob_next = 1; tree[2].ob_head = tree[2].ob_tail = 3;
    tree[3].ob_next = 2; tree[3].ob_type = G_TITLE;
    tree[3].ob_spec = (LONG)(intptr_t)" File ";
    tree[4].ob_next = 0; tree[4].ob_head = tree[4].ob_tail = 5;
    tree[5].ob_next = 4; tree[5].ob_head = 6; tree[5].ob_tail = count - 1;
    tree[5].ob_type = G_BOX;
    for (WORD i = 6; i < count; ++i) {
        tree[i].ob_type = G_STRING;
        tree[i].ob_spec = (LONG)(intptr_t)" Entry ";
        tree[i].ob_next = i + 1 < count ? i + 1 : 5;
    }
    tree[count - 1].ob_flags = LASTOB;
}

int main(void) {
    OBJECT tree[257];
    const WORD counts[] = {37, 38, 54, 65, 256};
    assert(appl_init() > 0);
    for (unsigned i = 0; i < sizeof(counts) / sizeof(counts[0]); ++i) {
        menu_tree(tree, counts[i]);
        assert(menu_bar(tree, 1) == 1);
        assert(menu_icheck(tree, counts[i] - 1, 1) == 1);
        assert(menu_ienable(tree, counts[i] - 1, 0) == 1);
        assert(menu_bar(tree, 0) == 1);
    }
    menu_tree(tree, 257);
    assert(menu_bar(tree, 1) <= 0);
    assert(appl_exit() == 1);
    puts("Complete menu transport: 32/33/49 strings and 65/256 objects passed");
    return 0;
}
