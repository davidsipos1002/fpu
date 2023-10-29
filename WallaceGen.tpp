#pragma once

#include "WallaceGen.h"

template <uint32_t N>
mul::WallaceGen<N>::WallaceGen(bool file) : file(file),
                                            name("wallace_tree_" + std::to_string(N)),
                                            current_level(1), current_column(0)
{
    if (file)
        os = new std::ofstream(name + ".vhd");
    else
        os = &std::cout;
}

template <uint32_t N>
mul::WallaceGen<N>::WallaceGen(std::ostream *os) : os(os) {}

template <uint32_t N>
mul::WallaceGen<N>::~WallaceGen()
{
    if (file)
    {
        static_cast<std::ofstream *>(os)->close();
        delete os;
    }
}

template <uint32_t N>
void mul::WallaceGen<N>::printEntity() const
{
    *os << "entity " << name << " is" << std::endl;
    *os << "\t\tPort (" << std::endl;
    *os << "\t\t\tx : in STD_LOGIC_VECTOR(" << N - 1 << " downto 0);" << std::endl;
    *os << "\t\t\ty : in STD_LOGIC_VECTOR(" << N - 1 << " downto 0);" << std::endl;
    *os << "\t\t\tp : out STD_LOGIC_VECTOR(" << (N << 1) - 1 << " downto 0);" << std::endl;
    *os << "\t\t);" << std::endl;
    *os << "end " << name << ";" << std::endl;
}

template <uint32_t N>
void mul::WallaceGen<N>::printSignals() const
{
    for (auto &signal : signals)
        *os << "signal " << signal << " : std_logic;" << std::endl;
    *os << "signal final_x : std_logic_vector (" << (N << 1) - 1 << " downto 0);" << std::endl;
    *os << "signal final_y : std_logic_vector (" << (N << 1) - 1 << " downto 0);" << std::endl;
}

template <uint32_t N>
void mul::WallaceGen<N>::printInitializer() const
{
    const uint32_t res_width = N << 1;

    for (uint32_t c = 0; c < N;c++)
    {
        for (uint32_t j = 0;j <= c;j++)
            *os << "l1c" << c << "_" << j << "<= " << "x(" << c - j << ") and y(" << j << ");" << std::endl;
    }
    for (uint32_t c = N;c < res_width;c++)
    {
        uint32_t indx = N - 1;
        for(uint32_t j = 0;j < res_width - c - 1;j++)
        {
            *os << "l1c" << c  << "_" << j << "<= " << "x(" << indx << ") and y(" << c - indx << ");" << std::endl;
            indx--;
        }
    }
}

template <uint32_t N>
void mul::WallaceGen<N>::printHalfAdders() const
{
    for (uint32_t i = 0;i < half_adders.size();i++)
    {
        const half_adder &ha = half_adders[i];
        *os << "halfadder" << i << ": half_adder port map(x => "
            << ha.x << ", y => " << ha.y << ", s => " << ha.sum
            << ", cout => " << ha.carry_out << ");" << std::endl;
    }
}

template <uint32_t N>
void mul::WallaceGen<N>::printFullAdders() const
{
    for (uint32_t i = 0;i < full_adders.size();i++)
    {
        const full_adder &fa = full_adders[i];
        *os << "fulladder" << i << ": full_adder port map(x => "
            << fa.x << ", y => " << fa.y << ", cin => " << fa.carry_in
            << ", s => " << fa.sum << ", cout => " << fa.carry_out << ");" << std::endl;
    }
}

template <uint32_t N>
void mul::WallaceGen<N>::printFinalAdder() const
{
    const int res_width = N << 1;

    *os << "final_x <= ";
    for (int c = res_width - 1;c >= 0;c--)
    {
        *os << columns[current_column][c][0];
        if (c != 0)
            *os << " & ";
    }
    *os << ";";

    *os << std::endl;
    *os << "final_y <= ";
    for (int c = res_width - 1; c >= 0;c--)
    {
        if (columns[current_column][c].size() == 2)
            *os << columns[current_column][c][1];
        else
            *os << "b\"0\"";
        if (c != 0)
            *os << " & ";
    }
    *os << ";"<<std::endl;

    *os << "final_adder: carry_lookahead_adder_" << (N << 1) << " port map(final_x, final_y, '0', p);" << std::endl;
}

template <uint32_t N>
void mul::WallaceGen<N>::initializeLevels()
{
    const uint32_t res_width = N << 1;

    for (uint32_t i = 0;i < N;i++)
    {
        for (uint32_t j = 0; j < i + 1; j++)
        {
            columns[0][i].push_back({1, i, j});
            signals.push_back({1, i, j});
        }
    }
    for (uint32_t i = N;i < res_width - 1;i++)
    {
        for (uint32_t j = 0; j < res_width - i - 1; j++)
        {
            columns[0][i].push_back({1, i, j});
            signals.push_back({1, i, j});
        }
    }
}

template <uint32_t N>
mul::half_adder mul::WallaceGen<N>::generateHalfAdder(const mul::signal x, const mul::signal y,
                                                      std::vector<uint32_t> &column_index) const
{
    uint32_t column = x.column;
    signal sum = {current_level + 1, column, column_index[column]++};
    signal carry_out = {current_level + 1, column + 1, column_index[column + 1]++};
    return {x, y, sum, carry_out};
}

template <uint32_t N>
mul::full_adder mul::WallaceGen<N>::generateFullAdder(const signal x, const signal y,
                                                      const signal carry_in, std::vector<uint32_t> &column_index) const
{
    uint32_t column = x.column;
    signal sum = {current_level + 1, column, column_index[column]++};
    signal carry_out = {current_level + 1, column + 1, column_index[column + 1]++};
    return {x, y, carry_in, sum, carry_out};
}

template <uint32_t N>
bool mul::WallaceGen<N>::reduceLevel()
{
    static const uint32_t res_width = N << 1;
    static std::vector<uint32_t> column_index;
    static auto addHalfAdder = [this] (std::vector<signal> *next, uint32_t c, half_adder ha) {
        half_adders.push_back(ha);
        next[c].push_back(ha.sum);
        next[c + 1].push_back(ha.carry_out);
        signals.push_back(ha.sum);
        signals.push_back(ha.carry_out);
    };
    static auto addFullAdder = [this] (std::vector<signal> *next, uint32_t c, full_adder fa) {
        full_adders.push_back(fa);
        next[c].push_back(fa.sum);
        next[c + 1].push_back(fa.carry_out);
        signals.push_back(fa.sum);
        signals.push_back(fa.carry_out);
    };

    bool ret = true;
    std::vector<signal> *curr = columns[current_column];
    std::vector<signal> *next = columns[1 - current_column];

    for (uint32_t c = 0; c < res_width; c++)
        next[c].clear();

    column_index.clear();
    for (uint32_t c = 0; c <= res_width; c++)
        column_index.push_back(0);

    for (uint32_t c = 0; c < res_width; c++)
    {
        if (curr[c].size() == 1)
            next[c].push_back(curr[c][0]);
        else if (curr[c].size() == 2)
            addHalfAdder(next, c, generateHalfAdder(curr[c][0], curr[c][1], column_index));
        else if (curr[c].size() >= 3)
        {
            for (uint32_t j = 0;j < curr[c].size() / 3; j++)
                addFullAdder(next, c, generateFullAdder(curr[c][3 * j],
                                                        curr[c][3 * j + 1], curr[c][3 * j + 2], column_index));

            uint32_t remainder = curr[c].size() % 3;
            uint32_t j = 3 * (curr[c].size() / 3);
            if (remainder == 1)
                next[c].push_back(curr[c][j]);
            else if (remainder == 2)
                addHalfAdder(next, c, generateHalfAdder(curr[c][j], curr[c][j + 1], column_index));
        }

        if (next[c].size() >= 3)
            ret = false;
    }

    current_level++;
    current_column = 1 - current_column;

    return ret;
}

template <uint32_t N>
void mul::WallaceGen<N>::generateTree()
{
    initializeLevels();
    bool done = false;
    while (!done)
       done = reduceLevel();
}

template <uint32_t N>
void mul::WallaceGen<N>::printTree() const
{
    printEntity();
    *os << std::endl;
    *os << "architecture arch of " << name << std::endl;
    *os << std::endl;
    printSignals();
    *os << std::endl;
    *os << "begin" << std::endl;
    printInitializer();
    *os << std::endl;
    printHalfAdders();
    *os << std::endl;
    printFullAdders();
    *os << std::endl;
    printFinalAdder();
    *os << std::endl;
    *os << "end arch;" << std::endl;
}