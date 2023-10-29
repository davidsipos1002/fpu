#ifndef WALLACETREEGENERATOR_WALLACEGEN_H
#define WALLACETREEGENERATOR_WALLACEGEN_H

#include <iostream>
#include <fstream>
#include <string>
#include <cstdint>

namespace mul
{

    struct signal
    {
        uint32_t level;
        uint32_t column;
        uint32_t index;
    };

    struct half_adder
    {
        signal x;
        signal y;
        signal sum;
        signal carry_out;
    };

    struct full_adder
    {
        signal x;
        signal y;
        signal carry_in;
        signal sum;
        signal carry_out;
    };

    std::ostream& operator<<(std::ostream &os, signal s)
    {
        return os << "l" << s.level << "c" << s.column << "_" << s.index;
    }

    std::ostream& operator<<(std::ostream &os, half_adder ha)
    {
        return os << "a: " << ha.x << " b: " << ha.y << " s: " << ha.sum << " cout:" << ha.carry_out;
    }

    std::ostream& operator<<(std::ostream &os, full_adder fa)
    {
        return os << "a: " << fa.x << " b: " << fa.y  << " cin: " << fa.carry_in<< " s: "
            << fa.sum << " cout:" << fa.carry_out;
    }

    template <uint32_t N = 2>
    class WallaceGen
    {
        public:
            explicit WallaceGen(bool file);
            explicit WallaceGen(std::ostream *os);
            ~WallaceGen();
            void generateTree();
            void printTree() const;

        private:
            bool file;
            std::ostream *os;
            std::string name;
            std::vector<signal> signals;
            std::vector<half_adder> half_adders;
            std::vector<full_adder> full_adders;
            uint32_t current_level;
            uint8_t current_column;
            std::vector<signal> columns[2][(N << 1) + 1];
            void printEntity() const;
            void printSignals() const;
            void printInitializer() const;
            void printHalfAdders() const;
            void printFullAdders() const;
            void printFinalAdder() const;
            void initializeLevels();
            half_adder generateHalfAdder(signal x, signal y,
                                         std::vector<uint32_t> &column_index) const;
            full_adder generateFullAdder(signal x, signal y,
                                         signal carry_in,
                                         std::vector<uint32_t> &column_index) const;
            bool reduceLevel();
    };
}

#include "WallaceGen.tpp"

#endif //WALLACETREEGENERATOR_WALLACEGEN_H
