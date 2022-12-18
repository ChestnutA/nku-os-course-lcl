#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>

// LAB2 CHALLENGE 1: MY CODE
// functions: `buddy_init`, `buddy_init_memmap`,
// `buddy_alloc_pages`, `buddy_free_pages`.

uint32_t* buddy_longest;
uint32_t buddy_max_pages;

#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) (((index) + 1) / 2 - 1)

static struct Page* buddy_base;

static inline uint32_t MAX(uint32_t a, uint32_t b) {return ((a) > (b) ? (a) : (b));}
static inline bool is_pow_of_2(uint32_t x) { return !(x & (x - 1)); }
static inline uint32_t next_pow_of_2(uint32_t x)
{
	if (is_pow_of_2(x)) return x;
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	return x + 1;
}

static void
buddy_init(void) {
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
	assert(n > 0);
	// 最大管理页数：不超过n的最大的2的幂次
	size_t max_pages = 1;
	for (size_t i = 1; i < 31; i++)
	{
		// 需要一个存储longest数组的页
		if (max_pages + max_pages / 512 >= n)
		{
			max_pages >>= 1;
			break;
		}
		max_pages <<= 1;
	}
	// 存储longest需要的页数
	size_t longest_array_pages = max_pages / 512 + 1;

	buddy_longest = (uint32_t*)KADDR(page2pa(base));
	buddy_max_pages = max_pages;

	uint32_t node_size = max_pages * 2;
	for (uint32_t i = 0; i < 2*max_pages-1; i++)
	{
		if (is_pow_of_2(i+1)) node_size >>= 1;
		buddy_longest[i] = node_size;
	}

	for (int i = 0; i < longest_array_pages; i++)
	{
		struct Page *p = base + i;
		SetPageReserved(p);
	}

	struct Page *p = base + longest_array_pages;
	buddy_base = p;
    for (; p != base + n; p ++) {
		assert(PageReserved(p));
		ClearPageReserved(p);
		SetPageProperty(p);
		set_page_ref(p, 0);
    }
}

static struct Page *
buddy_alloc_pages(size_t n) {
	assert(n > 0);
	n = next_pow_of_2(n);
	if (n > buddy_longest[0]) {
		return NULL;
	}

	// 从根节点遍历二叉树
	uint32_t index = 0;
	// 当前节点大小 （p->property）
	uint32_t node_size;

	// 寻找合适内存块
	for (node_size = buddy_max_pages; node_size != n; node_size >>= 1) 
	{
		if (buddy_longest[LEFT_LEAF(index)] >= n)
			index = LEFT_LEAF(index);
		else
			index = RIGHT_LEAF(index);
	}

	// 分配此节点下的所有页
	buddy_longest[index] = 0;
	// 找到页位置
	uint32_t offset = (index + 1) * node_size - buddy_max_pages;
	struct Page* new_page = buddy_base + offset, * p;
	for (p = new_page; p != new_page+node_size; p++)
	{
		set_page_ref(p, 0); // init时没有设置
		ClearPageProperty(p); // 每一页都Clear
	}

	// 更新所有父节点
	while (index) {
		index = PARENT(index);
		buddy_longest[index] = MAX(
			buddy_longest[LEFT_LEAF(index)], 
			buddy_longest[RIGHT_LEAF(index)]);
	}
	return new_page;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
	assert(n > 0);
	n = next_pow_of_2(n);
	// base作为叶节点在longest中的位置
	uint32_t index = (uint32_t)(base - buddy_base) + buddy_max_pages - 1;
	uint32_t node_size = 1;

	// 向上找到第一个为0的节点
	while (buddy_longest[index] != 0)
	{
		node_size <<= 1;
		assert(index != 0); // 否则出现错误，不存在分配过的节点
		index = PARENT(index);
	}

	struct Page *p = base;
	for (; p != base + n; p ++) {
	    assert(!PageReserved(p) && !PageProperty(p));
        // p->flags = 0;
	    SetPageProperty(p); // 分配时每页都Clear，此时每页都Set
	    set_page_ref(p, 0);
	}

	// 更新longest数组
	buddy_longest[index] = node_size;
	while (index != 0)
	{
		index = PARENT(index);
		node_size <<= 1;
		uint32_t left_size = buddy_longest[LEFT_LEAF(index)];
		uint32_t right_size = buddy_longest[RIGHT_LEAF(index)];

		if (left_size + right_size == node_size) // 相邻可以合并
			buddy_longest[index] = node_size;
		else
			buddy_longest[index] = MAX(left_size, right_size);
	}
}

static size_t
buddy_nr_free_pages(void) {
    return buddy_longest[0];
}

static void
buddy_check(void) {
	int all_pages = nr_free_pages();
	struct Page* p0, *p1, *p2, *p3, *p4;
	assert(alloc_pages(all_pages + 1) == NULL);

	p0 = alloc_pages(1);
	assert(p0 != NULL);
	
	p1 = alloc_pages(2);
	assert(p1 == p0 + 2);
	assert(!PageReserved(p0) && !PageReserved(p1));
	assert(!PageProperty(p0) && !PageProperty(p1));

	p2 = alloc_pages(1);
	assert(p2 == p0 + 1);

	p3 = alloc_pages(2);
	assert(p3 == p0 + 4);
	assert(!PageProperty(p3) && !PageProperty(p3 + 1) && PageProperty(p3 + 2));

	free_pages(p1, 2);
	assert(PageProperty(p1) && PageProperty(p1 + 1));
	assert(p1->ref == 0);

	free_pages(p0, 1);
	free_pages(p2, 1);

	p4 = alloc_pages(2);
	assert(p4 == p0);
	free_pages(p4, 2);
	assert((*(p4 + 1)).ref == 0);

	assert(nr_free_pages() == 16384 /2);

	free_pages(p3, 2);

	assert(nr_free_pages() == 16384);

	p1 = alloc_pages(33);
	free_pages(p1, 64);

	assert(nr_free_pages() == 16384);
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "default_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
