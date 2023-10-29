#include <iostream>
#include <ios>
#include <iomanip>
#include <string>
#include <stdlib.h>
#include <fstream>
#include <Windows.h>
#include <sstream>

HANDLE openConnection(const TCHAR* port)
{
    return CreateFile(port,
        GENERIC_READ | GENERIC_WRITE,
        0,
        NULL,
        OPEN_EXISTING,
        0,
        NULL);
}

bool closeConnection(HANDLE h)
{
    return CloseHandle(h);
}

bool getCurrentPortState(HANDLE h, DCB *dcb)
{
    SecureZeroMemory(dcb, sizeof(DCB));
    dcb->DCBlength = sizeof(DCB);
    return GetCommState(h, dcb);
}

bool setPortState(HANDLE h, DCB* dcb)
{
    return SetCommState(h, dcb);
}

bool transmitByte(HANDLE h, char* data)
{
    return WriteFile(h, data, 1, NULL, NULL);
}

bool waitForReceiveEvent(HANDLE h)
{
    DWORD eventMask = 0;
    SetCommMask(h, EV_RXCHAR);
    return WaitCommEvent(h, &eventMask, NULL);
}

int readRegister(HANDLE h, float *result, bool *overflow, bool *underflow)
{
    DWORD bytesRead = 0;
    DWORD total = 0;
    char buffer[5];
    do
    {
        ReadFile(h, buffer, 5, &bytesRead, NULL);
        total += bytesRead;
    }
    while (total < 5);
    *result = *((float*) buffer);
    *overflow = buffer[4] & 0x2;
    *underflow = buffer[4] & 0x1;
    return bytesRead;
}

void sendInstruction(HANDLE h, int reg0, int reg1, float data, char type)
{
    long long instr = 0;
    if (!type)
        instr |= *((unsigned int*)&data);
    else
        instr |= reg1;
    instr |= ((long long) reg0 << 32);
    instr |= ((long long) type << 37);
    std::cout << "Sending instruction: 0x" << std::hex << std::setw(12) << std::setfill('0') << instr << std::endl;
    transmitByte(h, ((char*)&instr) + 0);
    Sleep(1);
    transmitByte(h, ((char*)&instr) + 1);
    Sleep(1);
    transmitByte(h, ((char*)&instr) + 2);
    Sleep(1);
    transmitByte(h, ((char*)&instr) + 3);
    Sleep(1);
    transmitByte(h, ((char*)&instr) + 4);
    Sleep(1);
    transmitByte(h, ((char*)&instr) + 5);
}

void flush(HANDLE h) {
    PurgeComm(h, PURGE_RXABORT | PURGE_RXCLEAR | PURGE_TXABORT | PURGE_TXCLEAR);
}

void loop(std::istream &in, HANDLE h, bool test) {
    char c;
    int reg0, reg1;
    float imm;
    bool overflow;
    bool underflow;
    std::string instr;
    std::string line;
    bool start = false;
    int i = 0;
    int n = 0;
    std::istringstream ss;
    if (test) {
        std::getline(in, line);
        ss = std::istringstream(line);
        ss >> n;
    }
    while (true)
    {
        if (test) {
            if (i > n)
                break;
            if (!std::getline(in, line)) {
                break;
            }
            else {
                if (!start) {
                    std::cout << "TEST: " << line << std::endl;
                    start = true;
                    continue;
                }
                else if (!line.compare("end")) {
                    start = false;
                    i++;
                    std::cout << "END TEST" << std::endl;
                    continue;
                }
                else {
                    std::cout << line << std::endl;
                }
                ss = std::istringstream(line);
            }
        }
        flush(h);
        if (test) {
            ss >> instr;
        }
        else {
            in >> instr;
        }
        if (!instr.compare("fldi"))
        {
            if (test)
                ss >> reg0 >> imm;
            else
                in >> reg0 >> imm;
            sendInstruction(h, reg0, 0, imm, 0);
        }
        else if (!instr.compare("fldr"))
        {
            if (test)
                ss >> reg0 >> reg1;
            else
                in >> reg0 >> reg1;
            sendInstruction(h, reg0, reg1, 0, 2);
        }
        else if (!instr.compare("ftx"))
        {
            if (test)
                ss >> reg0;
            else
                in >> reg0;
            sendInstruction(h, reg0, 0, 0, 1);
            waitForReceiveEvent(h);
            readRegister(h, &imm, &overflow, &underflow);
            std::cout << "Received: " << imm;
            std::cout << " (0x" << *((int*)&imm) << std::hex << std::setw(8) << std::setfill('0')
                << " Overflow: " << overflow
                << " Underflow: " << underflow << ")" << std::endl;
        }
        else if (!instr.compare("fadd"))
        {
            if (test)
                ss >> reg0 >> reg1;
            else
                in >> reg0 >> reg1;
            sendInstruction(h, reg0, reg1, 0, 3);
        }
        else if (!instr.compare("fsub"))
        {
            if (test)
                ss >> reg0 >> reg1;
            else
                in >> reg0 >> reg1;
            sendInstruction(h, reg0, reg1, 0, 4);
        }
        else if (!instr.compare("fmul"))
        {
            if (test)
                ss >> reg0 >> reg1;
            else
                in >> reg0 >> reg1;
            sendInstruction(h, reg0, reg1, 0, 5);
        }
        else if (!instr.compare("clear"))
            system("cls");
        Sleep(1);
    }
}

int main()
{
    HANDLE h = openConnection(TEXT("COM4"));
    if (h == INVALID_HANDLE_VALUE)
    {
        std::cout << "Could not connect to the board" << std::endl;
        return -1;
    }
    std::cout << "Connected to the board" << std::endl;

    DCB dcb;
    if (!getCurrentPortState(h, &dcb))
    {
        std::cout << "Could not get current port state" << std::endl;
        return -1;
    }

    dcb.BaudRate = CBR_9600;
    dcb.ByteSize = 8;
    dcb.Parity = NOPARITY;
    dcb.StopBits = ONESTOPBIT;

    if (!setPortState(h, &dcb))
    {
        std::cout << "Could not set port state" << std::endl;
        return -1;
    }
   
    getCurrentPortState(h, &dcb);
    std::cout << "Port state:" << std::endl;
    std::cout << "\tBaudRate: " << dcb.BaudRate << std::endl;
    std::cout << "\tByteSize: " << (int) dcb.ByteSize << std::endl;
    std::cout << "\tParity: " << (int) dcb.Parity << std::endl;
    std::cout << "\tStopBits: " << (int) dcb.StopBits << std::endl;

    flush(h);
    
    std::cout << std::endl;
    std::cout << "Running tests" << std::endl;
    std::ifstream f("test.in");
    loop(f, h, true);

    flush(h);

    std::cout << std::endl;
    std::cout << "Entering interactive mode" << std::endl;
    loop(std::cin, h, false);

    closeConnection(h);
    return 0;
}
