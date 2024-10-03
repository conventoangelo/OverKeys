import 'package:win32/win32.dart';

int getVirtualKeyCode(String key) {
  switch (key) {
    case 'A':
      return VIRTUAL_KEY.VK_A;
    case 'B':
      return VIRTUAL_KEY.VK_B;
    case 'C':
      return VIRTUAL_KEY.VK_C;
    case 'D':
      return VIRTUAL_KEY.VK_D;
    case 'E':
      return VIRTUAL_KEY.VK_E;
    case 'F':
      return VIRTUAL_KEY.VK_F;
    case 'G':
      return VIRTUAL_KEY.VK_G;
    case 'H':
      return VIRTUAL_KEY.VK_H;
    case 'I':
      return VIRTUAL_KEY.VK_I;
    case 'J':
      return VIRTUAL_KEY.VK_J;
    case 'K':
      return VIRTUAL_KEY.VK_K;
    case 'L':
      return VIRTUAL_KEY.VK_L;
    case 'M':
      return VIRTUAL_KEY.VK_M;
    case 'N':
      return VIRTUAL_KEY.VK_N;
    case 'O':
      return VIRTUAL_KEY.VK_O;
    case 'P':
      return VIRTUAL_KEY.VK_P;
    case 'Q':
      return VIRTUAL_KEY.VK_Q;
    case 'R':
      return VIRTUAL_KEY.VK_R;
    case 'S':
      return VIRTUAL_KEY.VK_S;
    case 'T':
      return VIRTUAL_KEY.VK_T;
    case 'U':
      return VIRTUAL_KEY.VK_U;
    case 'V':
      return VIRTUAL_KEY.VK_V;
    case 'W':
      return VIRTUAL_KEY.VK_W;
    case 'X':
      return VIRTUAL_KEY.VK_X;
    case 'Y':
      return VIRTUAL_KEY.VK_Y;
    case 'Z':
      return VIRTUAL_KEY.VK_Z;
    case ' ':
      return VIRTUAL_KEY.VK_SPACE;
    case ',':
      return VIRTUAL_KEY.VK_OEM_COMMA;
    case '.':
      return VIRTUAL_KEY.VK_OEM_PERIOD;
    case ';':
      return VIRTUAL_KEY.VK_OEM_1;
    case '/':
      return VIRTUAL_KEY.VK_OEM_2;
    case '?':
      return VIRTUAL_KEY.VK_OEM_2;
    // No virtual key code for number sign
    case '#':
      return VIRTUAL_KEY.VK_3;
    case '[':
      return VIRTUAL_KEY.VK_OEM_4;
    case ']':
      return VIRTUAL_KEY.VK_OEM_6;
    // No separate keycode for single and double quotes
    case "'":
      return VIRTUAL_KEY.VK_OEM_7;
    case '"':
      return VIRTUAL_KEY.VK_OEM_7;
    case '=':
      return VIRTUAL_KEY.VK_OEM_PLUS;
    case '-':
      return VIRTUAL_KEY.VK_OEM_MINUS;
    default:
      return 0;
  }
}
