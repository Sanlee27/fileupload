<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.util.*"%>
<%@ page import = "java.sql.*"%>
<%
	// DB
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// ============ 페이징 =============
	// 현재 페이지
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	// 페이지 당 자료 개수
	int rowPerPage  = 5;
	if(request.getParameter("rowPerPage") != null) {
	      rowPerPage = Integer.parseInt(request.getParameter("rowPerPage"));
	}
	
	// 총 자료의 수
	int totalRow = 0; 
	String totalRowSql = null;
	PreparedStatement totalRowStmt = null;
	ResultSet totalRowRs = null; 
	
	// 개수 확인 쿼리
	totalRowSql = "SELECT COUNT(*) FROM board";
	totalRowStmt = conn.prepareStatement(totalRowSql);
	
	System.out.println(totalRowStmt + " : boardList totalRowStmt");
	
	totalRowRs = totalRowStmt.executeQuery();
	
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt(1); // 1 = count(*)
	}
	
	System.out.println(totalRow + " : boardList totalRow");
	
	// 시작행 = (현재 페이지 - 1) * 페이지별 자료개수 5개 | ex) 1페이지 > 0번행 2페이지 > 5번행 
	int startRow = (currentPage - 1) * rowPerPage;
	
	// 마지막행 = 시작행 + (페이지별 자료개수 5개 - 1 = 4) | ex) 1페이지 > 4번행 2페이지 > 9번행
	int endRow = startRow + (rowPerPage - 1);
	if(endRow > totalRow){ // 최대값은 totalRow여야함
		endRow = totalRow;
	}
	
	// 페이지 선택 버튼 개수
	int pagePerPage = 5;
	
	// 마지막 페이지
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){ // 딱 떨어진다면 상관없으나, 나머지가 있다면(잔여 행이 있다면)
		lastPage = lastPage + 1; // 1을 추가하여 그 페이지에 잔여행을 배치
	}
	
	// 페이지 선택 버튼 최소값 > 1~5 / 6~10 에서 1 / 6 / ,,,
	int minPage = ((currentPage - 1) / pagePerPage * pagePerPage) + 1;
	
	// 페이지 선택 버튼 최대값 > 1~5 / 6~10 에서 5 / 10 / ,,,
	int maxPage = minPage + (pagePerPage -1);
	if(maxPage > lastPage){ // lastPage = 18, maxPage가 20(16~20) 이면
		maxPage = lastPage; // maxPage를 lastPage == 18로 한다.
	}
	
	// =========================
			
	// 쿼리
	/*
	SELECT b.board_title boardTitle, f.origin_filename originFilename, f.save_filename saveFilename, path ~~~ ++
	FROM board b INNER JOIN board_file f
	ON b.board_no = f.board_no
	ORDER BY b.createdate DESC
	*/
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, path FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC LIMIT ?,?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, startRow);
	stmt.setInt(2, rowPerPage);
	ResultSet rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String,Object>>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("boardNo", rs.getInt("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("boardFileNo", rs.getInt("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
		m.put("saveFilename", rs.getString("saveFilename"));
		m.put("path", rs.getString("path"));
		list.add(m);
	}
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div class="container mt-3">
		<h1 style="text-align: center;">PDF 자료 목록</h1>
		<% 
			// 세션 유효성 검사(로그인 확인)
			if(session.getAttribute("loginMemberId") !=null){
		%>
				<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/logoutAction.jsp">로그아웃</a>
		<%
			} else {
		%>
				<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/login.jsp">로그인</a>
		<%
			}
		%>
		<a type="button" class="btn btn-outline-secondary" href = "<%=request.getContextPath()%>/addBoard.jsp">업로드하기</a>
		<br>
		<table class="table table-hover">
			<tr>
				<th>자료명</th>
				<th>파일명</th>
				<th>수정</th>
				<th>삭제</th>
			</tr>
			<%
				for(HashMap<String, Object> m : list){
			%>
					<tr>
						<td><%=(String)m.get("boardTitle") %></td>
						<%
							if(session.getAttribute("loginMemberId") !=null){
						%>
								<td>
									<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>">
										<%=(String)m.get("originFilename") %>
									</a>
								</td>
								<td><a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">수정</a></td>
								<td><a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">삭제</a></td>
							<%
								} else {
							%>
								<td>
									<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/login.jsp">
										<%=(String)m.get("originFilename") %>
									</a>
								</td>
								<td><a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/login.jsp">수정</a></td>
								<td><a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/login.jsp">삭제</a></td>
							<%
								}
							%>
					</tr>
			<%
				}
			%>
		</table>
	</div>
	<!-- ============= 페이지 ============= -->
	<div class="container mt-3">
		<ul class="pagination justify-content-center">
			<!-- 첫 페이지 버튼 항상 표시 -->
			<li>
				<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=1">첫페이지</a>&nbsp;
			</li>
		<%
			// 첫페이지가 아닐 경우 이전 버튼 표시 == 첫 페이지에선 표시 x 
			// 다음 pagePerPage의 첫행으로 넘기기 ex) pagePerPage=5(1~5) 중 3 페이지 에서 다음 버튼 누르면 6페이지 첫행으로 
			if(minPage > 1){
		%>		
				<li>
					<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=minPage-rowPerPage%>">이전</a>&nbsp;
				</li>
		<%	
			}
			
			// 첫페이지부터 마지막 페이지까지 버튼 표시
			// 현재 페이지 일 경우 숫자만 표시 / 나머지 페이지는 링크로 표시
			for(int i = minPage; i<=maxPage; i++){
				if(i == currentPage){
		%>
					<li>
						<a class="btn btn-secondary"><%=i%></a>
					</li>
		<%	
				} else {
		%>			
					<li>
						<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
					</li>
		<%			
				}
			}
			
			// 각 페이지 표시버튼이 마지막이 아닌 경우 다음 버튼 표시 == 마지막 페이지에선 표시x
			// 이전 pagePerPage의 첫행으로 넘기기 ex) pagePerPage=5(21~25) 중 23 페이지 에서 이전 버튼 누르면 16페이지 첫행으로
			if(maxPage != lastPage){
		%>	
				<li>
					<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=minPage+rowPerPage%>">다음</a>&nbsp;
				</li>
		<%
			}
		%>
			<!-- 마지막 페이지 버튼 -->	
		<%
			// 게시물이 없어 활성화된 페이지가 없으면 현재 페이지(1p) 고정
			if(lastPage == 0){
		%>
				<li>
					<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=1">마지막페이지</a>&nbsp;
				</li>
		<%
			} else {
		%>	
				<li>
					<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=lastPage%>">마지막페이지</a>&nbsp;
				</li>
		<%
			}
		%>		
		</ul>
	</div>
	<br>
	<div class="text-center">
		<!-- include 페이지 : copyright &copy; 구디아카데미 -->
		<jsp:include page="/copyright.jsp"></jsp:include>
	</div>
</body>
</html>