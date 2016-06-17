#pragma once

// http://stackoverflow.com/questions/453099/size-of-static-array
template<typename T, size_t N> size_t elmentsOfArray(T(&arr)[N]) { return N; }
