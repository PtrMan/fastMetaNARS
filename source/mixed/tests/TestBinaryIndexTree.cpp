#include "gtest/gtest.h"

#include "BinaryIndexTree.h"

// check for correct result after adding elements one after one
TEST(BinaryIndexTreeTest, Query1) {
	BinaryIndexTree<int64_t> tree;
	tree.setSize(8);
	tree.reset();

	tree.update(1, 10);

	bool found;
	size_t queryResultIndex = tree.find(9, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 0);

	queryResultIndex = tree.find(10, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 0);

	tree.update(2, 5);

	queryResultIndex = tree.find(11, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 1);

	queryResultIndex = tree.find(15, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 1);

	tree.update(3, 10);

	queryResultIndex = tree.find(16, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 2);

	queryResultIndex = tree.find(25, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 2);

	tree.update(4, 5);

	queryResultIndex = tree.find(26, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 3);

	queryResultIndex = tree.find(30, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 3);
}

TEST(BinaryIndexTreeTest, QueryBulk) {
	BinaryIndexTree<int64_t> tree;
	tree.setSize(8);
	tree.reset();

	tree.update(1, 10);
	tree.update(2, 5);
	tree.update(3, 10);
	tree.update(4, 5);

	bool found;
	size_t queryResultIndex = tree.find(10, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 0);

	queryResultIndex = tree.find(11, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 1);

	queryResultIndex = tree.find(15, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 1);

	queryResultIndex = tree.find(16, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 2);

	queryResultIndex = tree.find(25, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 2);

	queryResultIndex = tree.find(26, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 3);

	queryResultIndex = tree.find(30, found, BinaryIndexTree<int64_t>::EnumFindType::ABOVE);
	EXPECT_TRUE(found);
	EXPECT_EQ(queryResultIndex, 3);
}
