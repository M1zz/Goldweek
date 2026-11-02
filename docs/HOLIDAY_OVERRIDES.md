# 공휴일 고침 (앱 업데이트 없이)

임시공휴일처럼 몇 주 전에야 정해지는 날을 앱 업데이트 없이 내려보낸다.
CloudKit 공개 데이터베이스에 `HolidayOverride` 기록을 하나 넣으면, 앱이 열릴 때(12시간에 한 번까지) 받아
앱 안 공휴일 표 위에 덮어쓴다. 코드는 `Goldweek/Services/HolidayOverrides.swift`.

- 컨테이너: `iCloud.com.Ysoup.LeaveWise` 의 공개 데이터베이스 (가족 공유와 같은 컨테이너, 여러 앱이 함께 쓰는 FeedbackHub 가 아니다)
- 받은 것은 기기에 남는다. 인터넷이 없으면 마지막으로 받은 대로 계산한다.
- 받기에 실패하면(오프라인, 기록 종류가 아직 없음) 가진 것을 그대로 쓴다.
- 받은 고침은 다음에 화면을 그릴 때 반영된다. 이미 열려 있는 화면은 다시 열거나 앱을 다시 켜야 바뀐다.

## 처음 한 번 (CloudKit Console, 사람)

1. **기록 종류 만들기** — Development 환경에서 Record Type `HolidayOverride`, 필드:

   | 필드 | 형식 | 뜻 |
   |---|---|---|
   | `country` | String | `Country.rawValue` (예: `korea`, `japan`, `germany`) |
   | `region` | String | 지역 공휴일이면 ISO 3166-2 (예: `DE-BY`). 나라 전체면 비움 |
   | `date` | String | `yyyy-MM-dd` |
   | `action` | String | `add`(더하기) · `remove`(빼기) · `rename`(이름만 바꾸기). 비우면 `add` |
   | `names` | String | 언어별 이름 JSON. 예: `{"ko":"임시공휴일","en":"Temporary Holiday"}` |
   | `active` | Int(64) | 0 이면 끈다(되돌리기). 비우면 켜짐 |

2. **인덱스** — `recordName` 을 Queryable 로. (앱이 조건 없이 전부 읽기 때문)

3. **권한 (꼭)** — Security Roles 에서 `HolidayOverride` 를
   - `_world`: Read 만
   - `_icloud` (로그인한 아무나): **Create 끄기**
   - `_creator`: Read · Write

   기본값이면 iCloud 에 로그인한 누구나 기록을 만들 수 있다. 그러면 가짜 공휴일이 모든 사용자에게 내려간다.

4. **Production 에 배포** — Deploy Schema Changes. 실제 사용자는 Production 데이터만 받는다.

## 임시공휴일 하나 넣기

Production 환경 → Records → `HolidayOverride` → New Record.

```
country  korea
date     2027-04-07
action   add
names    {"ko":"임시공휴일","en":"Temporary Public Holiday","ja":"臨時公休日"}
```

- 언어 코드는 `AppLanguage.rawValue` (ko, en, ja, zh, zh-Hant 등 — `Strings.swift` 맨 위). 없는 언어는 영어 이름, 그것도 없으면 아무 이름을 쓴다.
- 앱 안 표에 이미 있는 날을 고칠 때는 `rename` 이나 `remove`.
- 잘못 넣었으면 지우지 말고 `active` 를 0 으로. 지워도 되지만 끄면 무엇을 고쳤는지 남는다.

## 앱이 받지 않는 것 (한 번의 실수가 모두에게 가므로)

- 모르는 나라, `custom`
- 지난해보다 앞이거나 3년보다 먼 날
- 형식이 틀린 날짜, `add` · `rename` 인데 이름이 없는 것

## 공휴일 데이터 버전

`HolidayOverrideStore.dataVersion` = 앱 버전 + 받은 고침 중 가장 늦게 고친 시각 (예: `2.4.2+1800000000`).
휴가를 잡을 때 `LeaveRecord.holidayDataVersion` 에 남는다(백업에도 들어간다). 예전 기록은 비어 있다.
다음 단계(공휴일이 바뀌어 잡아 둔 계획에 영향이 있으면 알리기)에서 이 값으로 "바뀌기 전에 잡은 계획"을 가려낸다.

## 앱 안 표도 함께 고친다

고침은 급한 불을 끄는 것이다. 다음 앱 업데이트 때 `HolidayService.swift` 의 표(예: `getKoreanSpecialHolidays`)에도 넣고,
그 뒤 고침 기록은 `active` 0 으로 끈다. 같은 날이 두 번 들어가도 `add` 는 같은 이름이면 건너뛰지만, 이름이 다르면 두 줄이 된다.
