// savedToCSV.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "savedToCSV.h"

#define MAX_LOADSTRING 100

// Global Variables:
HINSTANCE hInst;                                // current instance
WCHAR szTitle[MAX_LOADSTRING] = _T("WoW Saved Variable to CSV");                  // The title bar text
WCHAR szWindowClass[MAX_LOADSTRING];            // the main window class name

// Forward declarations of functions included in this code module:
ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK    About(HWND, UINT, WPARAM, LPARAM);

OPENFILENAME file;
TCHAR szFile[260] = { 0 };
HWND hwnd;
HANDLE hf;

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPWSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    // TODO: Place code here.

    // Initialize global strings
    LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
    LoadStringW(hInstance, IDC_SAVEDTOCSV, szWindowClass, MAX_LOADSTRING);
    MyRegisterClass(hInstance);

    // Perform application initialization:
    if (!InitInstance (hInstance, nCmdShow))
    {
        return FALSE;
    }

    HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_SAVEDTOCSV));

    MSG msg;

    // Main message loop:
    while (GetMessage(&msg, nullptr, 0, 0))
    {
        if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }

    return (int) msg.wParam;
}



//
//  FUNCTION: MyRegisterClass()
//
//  PURPOSE: Registers the window class.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
    WNDCLASSEXW wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);

    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = WndProc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInstance;
    wcex.hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_SAVEDTOCSV));
    wcex.hCursor        = LoadCursor(nullptr, IDC_ARROW);
	wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+2); 
    wcex.lpszMenuName   = MAKEINTRESOURCEW(IDC_SAVEDTOCSV);
    wcex.lpszClassName  = szWindowClass;
    wcex.hIconSm        = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

    return RegisterClassExW(&wcex);
}

//
//   FUNCTION: InitInstance(HINSTANCE, int)
//
//   PURPOSE: Saves instance handle and creates main window
//
//   COMMENTS:
//
//        In this function, we save the instance handle in a global variable and
//        create and display the main program window.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   hInst = hInstance; // Store instance handle in our global variable

   HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);

   if (!hWnd)
   {
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

//
//  FUNCTION: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  PURPOSE: Processes messages for the main window.
//
//  WM_COMMAND  - process the application menu
//  WM_PAINT    - Paint the main window
//  WM_DESTROY  - post a quit message and return
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
    case WM_COMMAND:
        {
            int wmId = LOWORD(wParam);
            // Parse the menu selections:
            switch (wmId)
            {
            case IDM_ABOUT:
                DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
                break;
            case IDM_EXIT:
                DestroyWindow(hWnd);
                break;
            default:
                return DefWindowProc(hWnd, message, wParam, lParam);
            }
        }
        break;
    case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hWnd, &ps);
            // TODO: Add any drawing code that uses hdc here...
			FillRect(hdc, &ps.rcPaint, (HBRUSH)(COLOR_WINDOW+2));
            EndPaint(hWnd, &ps);
        }
        break;
    case WM_DESTROY:
        PostQuitMessage(0);
        break;
    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}

// Message handler for about box.
INT_PTR CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    UNREFERENCED_PARAMETER(lParam);
    switch (message)
    {
    case WM_INITDIALOG:
        return (INT_PTR)TRUE;

    case WM_COMMAND:
        if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
        {
            EndDialog(hDlg, LOWORD(wParam));
            return (INT_PTR)TRUE;
        }
        break;
    }
    return (INT_PTR)FALSE;
}

std::wstring OpenFile()
{
	ZeroMemory(&file, sizeof(file));
	file.lStructSize = sizeof(file);
	file.hwndOwner = hwnd;
	file.lpstrFile = szFile;
	file.lpstrFile[0] = '\0';
	file.nMaxFile = sizeof(szFile);
	file.lpstrFilter = _T("All\0*.*\0Text\0.TXT\0");
	file.nFilterIndex = 0;
	file.lpstrFileTitle = NULL;
	file.nMaxFileTitle = 0;
	file.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

	std::wstring filePath;

	if (GetOpenFileName(&file) == TRUE)
	{
		hf = CreateFile(file.lpstrFile, GENERIC_READ, 0, (LPSECURITY_ATTRIBUTES)NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, (HANDLE)NULL);
		filePath = szFile;
	}

	return filePath;
}

void ConvertToCSV()
{
	int line;
	std::vector<std::string> printBuffer;
	std::vector<std::string> numBuffer;

	std::ifstream savedVarFile;
	savedVarFile.open(&file, std::fstream::in);
	for (int i = 0; i < std::ios::end; i++)
	{
		//printBuffer[i].push_back(std::getline(savedVarFile, printBuffer));
		//numBuffer[i].push_back(std::getline(savedVarFile, numBuffer));
		std::getline(savedVarFile, printBuffer[i]);
		i++;
		//std::getline(savedVarFile, numBuffer[i]);
	}
	for (int i = 1; i < std::ios::end; i++)
	{
		std::getline(savedVarFile, numBuffer[i]);
		i++;
	}
	savedVarFile.close();

	std::ofstream csvFile;
	if (csvFile.open(file) == std::ios::fail)
	{
		csvFile.open(file, std::fstream::out);
	}
	if (csvFile.is_open)
	{

		csvFile << "Item, Count";
		//for loop i at 0, i+2
		//itembuffer at i, count at i+1
		for (int i = 0; i < numBuffer.max_size(); i + 2)
		{
			csvFile << printBuffer[i] + ", " + numBuffer[i + 1];
		}
		csvFile.close();
	}
	//open csv file
	//check if file exists, if not, create
	//clear file
	//write line by line until eof
	//consolidate? or consolidate as writing
}