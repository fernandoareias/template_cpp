#include <gtest/gtest.h>
#include "CppTemplate.h"

TEST(CppTemplateTest, HelloReturnsNonEmptyString)
{
    EXPECT_FALSE(CppTemplate::hello().empty());
}

TEST(CppTemplateTest, HelloContainsProjectName)
{
    EXPECT_NE(CppTemplate::hello().find("CppTemplate"), std::string::npos);
}
