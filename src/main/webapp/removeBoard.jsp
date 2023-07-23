<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "vo.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.util.*"%>    
<%	
	//세션 유효성 검사(로그인 유무)
	if(session.getAttribute("loginMemberId") == null) { // 로그인이 되어있지 않다면
		response.sendRedirect(request.getContextPath()+"/login.jsp"); // 로그인 페이지로
		return;
	}

	//유효성검사
	if(request.getParameter("boardNo") == null || request.getParameter("boardNo").equals(null)
		|| request.getParameter("boardFileNo") == null || request.getParameter("boardFileNo").equals(null)){
			response.sendRedirect(request.getContextPath()+"/boardList.jsp");
			return;
	}
	System.out.println(request.getParameter("boardNo") + " : removeBoard req boardNo");
	System.out.println(request.getParameter("boardFileNo") + " : removeBoard req boardFileNo");
	
	// 변수에 저장
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
	
	// DB
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);    
	
	// 정보 조회 쿼리
	String boardSql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.save_filename saveFilename FROM board b INNER JOIN board_file f ON b.board_no = f.board_no WHERE b.board_no =? AND f.board_file_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setInt(1, boardNo);
	boardStmt.setInt(2, boardFileNo);
	ResultSet rs = boardStmt.executeQuery();
	HashMap<String, Object> map = null;
	if(rs.next()){
		map = new HashMap<>();
		map.put("boardNo", rs.getInt("boardNo"));
		map.put("boardTitle", rs.getString("boardTitle"));
		map.put("boardFileNo", rs.getInt("boardFileNo"));
		map.put("saveFilename", rs.getString("saveFilename"));
	}
%>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>remove Board</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div class="container mt-3">
		<h1 style="text-align: center;">board &amp; boardFile 삭제</h1>
		<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/boardList.jsp">목록으로</a>
		<br>
		<form action="<%=request.getContextPath()%>/removeBoardAction.jsp" method="post" enctype="multipart/form-data">
			<input type="hidden" name="boardNo" value=<%=map.get("boardNo")%>>
			<input type="hidden" name="boardFileNo" value=<%=map.get("boardFileNo")%>>
			<table class="table table-hover">
				<tr>
					<th>자료명</th>
					<td>
						<%=map.get("boardTitle")%>
					</td>
				</tr>
				<tr>
					<th>파일명</th>
					<td><%=map.get("saveFilename")%></td>
				</tr>
			</table>
			<button type="submit" class="btn btn-outline-secondary">삭제</button>
		</form>
	</div>
</body>
</html>